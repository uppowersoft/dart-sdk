import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tinode/src/models/packet.dart';
import 'package:tinode/src/models/packet-data.dart';
import 'package:tinode/src/models/server-messages.dart';
import 'package:tinode/src/services/packet-generator.dart';
import 'package:tinode/src/models/packet-types.dart' as PacketTypes;
import 'package:tinode/src/models/message-status.dart' as MessageStatus;

class Message {
  bool echo;
  int _status;
  DateTime ts;
  String from;
  bool cancelled;
  dynamic content;
  String topicName;
  bool noForwarding;

  PacketGenerator _packetGenerator;

  PublishSubject<int> onStatusChange = PublishSubject<int>();

  Message(this.topicName, this.content, this.echo) {
    _status = MessageStatus.NONE;
    _packetGenerator = GetIt.I.get<PacketGenerator>();
  }

  Packet asPubPacket() {
    var packet = _packetGenerator.generate(PacketTypes.Pub, topicName);
    PubPacketData data = packet.data;
    data.content = content;
    data.noecho = !echo;
    packet.data = data;
    return packet;
  }

  DataMessage asDataMessage(String from, int seq) {
    return DataMessage(
      content: content,
      from: from,
      noForwarding: false,
      head: {},
      hi: null,
      topic: topicName,
      seq: seq,
      ts: ts,
    );
  }

  void setStatus(int status) {
    _status = status;
    onStatusChange.add(status);
  }

  int getStatus() {
    return _status;
  }

  void resetLocalValues() {
    ts = null;
    setStatus(MessageStatus.NONE);
  }
}
