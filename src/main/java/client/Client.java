package client;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.Socket;

import org.zeromq.ZMQ;
import org.zeromq.ZContext;
import org.zeromq.SocketType;

import protos.Protos.Authentication;
import protos.Protos.Produce;
import protos.Protos.ServerResponse;
import protos.Protos.Transaction;

public class Client {
    public static void main(String[] args) {
        try {
            Socket s = new Socket("localhost", 1234);
            Thread cts = new ClientToSocket(s);
            cts.start();
        } catch (Exception e) {
            System.out.println("Não foi possível conectar ao servidor.");
        }
    }
}

class ClientToSocket extends Thread {
    Socket socket;
    InputStream is;
    OutputStream os;
    String username;
    BufferedReader stdin = new BufferedReader(new InputStreamReader(System.in));

    public ClientToSocket(Socket cli) throws IOException {
        this.socket = cli;
        is = cli.getInputStream();
        os = cli.getOutputStream();
        this.username = null;
    }

    private void clearTerminal() {
        System.out.print("\033[H\033[2J");
        System.out.flush();
    }

    private void waitConfirmation() throws IOException {
        System.out.print("\nClique no ENTER para continuar...");
        System.out.flush();
        this.stdin.readLine();
    }

    private int readInt() throws IOException {
        while (true) {
            try {
                return Integer.parseInt(this.stdin.readLine());
            } catch (NumberFormatException exc) {
                System.out.println("Por favor, introduza um número");
            }
        }
    }

    private void importerMenu() throws IOException {
        ZContext context = new ZContext();
        ZMQ.Socket subSocket = context.createSocket(SocketType.SUB);
        subSocket.connect("tcp://localhost:7777");

        Thread s = new Subscriptions(subSocket);
        s.start();

        while (true) {
            StringBuilder main = new StringBuilder();
            main.append("O que queres fazer?\n");
            main.append("1 - Oferta de encomenda\n");
            main.append("2 - Subscrever notificações\n");
            main.append("3 - Cancelar notificações\n");
            main.append("4 - Exit\n");

            clearTerminal();
            System.out.println(main);

            int escolha;
            do {
                escolha = readInt();
            } while (escolha < 1 || escolha > 4);

            switch (escolha) {
            case 1:
                System.out.print("Fabricante: ");
                System.out.flush();

                break;
            case 2: {
                System.out.print("Fabricante: ");
                System.out.flush();

                String producer = this.stdin.readLine();
                subSocket.subscribe(producer);
                break;
            }
            case 3: {
                System.out.print("Fabricante: ");
                System.out.flush();

                String producer = this.stdin.readLine();
                subSocket.unsubscribe(producer);
                break;
            }
            case 4:
                clearTerminal();
                context.close();
                System.exit(1);
                break;
            }
            waitConfirmation();
        }
    }

    private void producerMenu() throws IOException {
        ZContext context = new ZContext();
        ZMQ.Socket pubSocket = context.createSocket(SocketType.PUB);
        pubSocket.connect("tcp://localhost:7777");

        // socket.send("pqpqpq");

        while (true) {
            StringBuilder main = new StringBuilder();
            main.append("O que queres fazer?\n");
            main.append("1 - Oferta de produção\n");
            main.append("2 - Exit\n");

            clearTerminal();
            System.out.println(main);

            int escolha;
            do {
                escolha = readInt();
            } while (escolha < 1 || escolha > 2);

            switch (escolha) {
            case 1:
                Transaction.Builder txn = Transaction.newBuilder();
                Produce.Builder prod = Produce.newBuilder();

                System.out.print("Nome do produto: ");
                System.out.flush();
                prod.setProductName(this.stdin.readLine());

                System.out.print("Quantidade mínima: ");
                System.out.flush();
                prod.setMinimumAmount(this.readInt());

                System.out.print("Quantidade máxima: ");
                System.out.flush();
                prod.setMaximumAmount(this.readInt());

                System.out.print("Preço mínimo por produto: ");
                System.out.flush();
                prod.setMinimumUnitaryPrice(this.readInt());

                System.out.print("Período de negociação (segundos): ");
                System.out.flush();
                prod.setNegotiationPeriod(this.readInt());

                txn.setProduce(prod.build());
                txn.build().writeDelimitedTo(os);
                break;
            case 2:
                clearTerminal();
                context.close();
                System.exit(1);
                break;
            }
            waitConfirmation();
        }
    }

    public void run() {

        try {
            String role;

            while (true) {
                Authentication.Builder auth = Authentication.newBuilder();

                // Verificar o papel do utilizador
                System.out.print("É um (f)abricante ou um (i)mportador? ");
                System.out.flush();
                role = stdin.readLine();
                if (role.equals("f"))
                    auth.setUserType(Authentication.UserType.PRODUCER);
                else if (role.equals("i"))
                    auth.setUserType(Authentication.UserType.IMPORTER);
                else {
                    System.out.println("Não é nenhum dos papéis válidos.");
                    continue;
                }

                // Verificar credenciais do utilizador
                System.out.print("Deseja fazer (l)ogin ou (r)egistar-se? ");
                System.out.flush();
                String method = stdin.readLine();
                if (method.equals("r"))
                    auth.setType(Authentication.AuthType.REGISTER);
                else if (method.equals("l"))
                    auth.setType(Authentication.AuthType.LOGIN);
                else {
                    System.out.println("Não é nenhum dos métodos válidos.");
                    continue;
                }

                System.out.print("Nome de utilizador: ");
                System.out.flush();
                String username = stdin.readLine();
                auth.setUsername(username);

                System.out.print("Palavra-passe: ");
                System.out.flush();
                auth.setPassword(stdin.readLine());

                // Try to authenticate
                auth.build().writeDelimitedTo(os);

                // Receive authentication confirmation
                ServerResponse aVal = ServerResponse.parseDelimitedFrom(is);
                if (!aVal.getSuccess()) {
                    if (method.equals("l"))
                        System.out.println("O nome do utilizador não existe ou a palavra passe está incorreta.");
                    else
                        System.out.println("O nome do utilizador já existe.");
                    continue;
                }

                System.out.println("Autenticação bem sucedida.");

                this.username = username;

                break;
            }

            waitConfirmation();

            // Iniciar thread para ler do socket para o terminal
            Thread stc = new SocketToClient(is);
            stc.start();

            if (role.equals("f"))
                producerMenu();
            else
                importerMenu();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

class SocketToClient extends Thread {
    InputStream is;

    public SocketToClient(InputStream is) throws IOException {
        this.is = is;
    }

    public void run() {
        try {
            while (true) {
                // DO SOMETHING
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

class Subscriptions extends Thread {
    ZMQ.Socket subSocket;

    public Subscriptions(ZMQ.Socket subSocket) throws IOException {
        this.subSocket = subSocket;
    }

    public void run() {
        while (true) {
            byte[] b = this.subSocket.recv();
            System.out.println(new String(b));
        }
    }
}
