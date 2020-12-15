//version 1.2.1

const dgram = require("dgram");

const PacketType = {
    HEARTBEAT: 0,
    PLAYERINFO: 1,
    SERVERINFO: 2,
    REQUESTSERVERINFO: 3
}


class Client {
    constructor(address, port, serverAddress, lastHeartbeat) {
        this.address = address;
        this.port = port;
        this.serverAddress = serverAddress;
        this.lastHeartbeat = lastHeartbeat;
    }
}


class PacketHandler {
    constructor(socket) {
        this.socket = socket;
        this.clientList = [];
        this.lastHeartbeatCheck = 0;
        this.ipLastPacketTime = {};
    }

    makePacket(packet, type) {
        return `${type}${packet}`;
    }

    makeRequestServerInfo(remote) {
        let packet = this.makePacket("", PacketType.REQUESTSERVERINFO);
        this.socket.send(packet, remote.port, remote.address);
    }

    handlePlayerInfo(packet, remote) {
        let fromClient = this.clientList.find(client => client.address == remote.address);
        if (typeof fromClient === "undefined") {
            this.makeRequestServerInfo(remote);
            return;
        }

        let sameServerClients = this.clientList.filter(client => client.serverAddress == fromClient.serverAddress && client.address != fromClient.address)
        sameServerClients.forEach(client => {
            this.socket.send(this.makePacket(packet, PacketType.PLAYERINFO), client.port, client.address);
        });
    }

    handleHeartbeat(remote) {
        let client = this.clientList.find(obj => obj.address == remote.address);
        let curTime = new Date().getTime() / 1000;

        if (typeof client !== "undefined") {
            client.lastHeartbeat = curTime;
        } else {
            this.makeRequestServerInfo(remote);
        }

        if (curTime - this.lastHeartbeatCheck >= 60) {
            this.clientList = this.clientList.filter(client => curTime - client.lastHeartbeat < 60);
            this.lastHeartbeatCheck = curTime;
        }
    }

    handleServerInfo(packet, remote) {
        let client = this.clientList.find(obj => obj.address == remote.address);
        if (typeof client !== "undefined") {
            client.serverAddress = packet;
        } else {
            client = new Client(remote.address, remote.port, packet, new Date().getTime() / 1000);
            this.clientList.push(client);
        }
    }

    handlePacket(packet, remote) {
        let type = parseInt(packet.substring(0, 1));
        packet = packet.substring(1);
        let curTime = new Date().getTime() / 1000

        if (packet.length > 512)
            return;

        if (remote.address in this.ipLastPacketTime) {
            if (curTime - this.ipLastPacketTime[remote.address] < 0.0625) {
                return;
            }
        }

        this.ipLastPacketTime[remote.address] = curTime

        switch (type) {
            case PacketType.HEARTBEAT:
                this.handleHeartbeat(remote);
                break;
            case PacketType.SERVERINFO:
                this.handleServerInfo(packet, remote);
                break;
            case PacketType.PLAYERINFO:
                this.handlePlayerInfo(packet, remote);
                break;
        }
    }
}

function main() {
    const port = 57020;
    const socket = dgram.createSocket("udp4");

    let packetHandler = new PacketHandler(socket);

    socket.on("listening", () => {
        console.log(`Server is listening on port ${port}.`);
    });

    socket.on("message", (msg, remote) => {
        packetHandler.handlePacket(msg.toString(), remote);
    });

    socket.on("error", (err) => {
        console.log(`Server error:\n${err.stack}`);
        socket.close();
    });

    socket.bind(port, "0.0.0.0");
}

if (require.main == module) {
    main();
}
