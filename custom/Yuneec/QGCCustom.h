/*!
 * @file
 *   @brief ST16 Controller
 *   @author Gus Grubba <mavlink@grubba.com>
 *
 */

#ifndef YUNEEC_M4_H
#define YUNEEC_M4_H

#include <QObject>
#include <QTimer>
#include "QGCLoggingCategory.h"
#include "m4Defines.h"

Q_DECLARE_LOGGING_CATEGORY(YuneecLog)

//-- Comments (Google) translated from Chinese.
//-- Nowhere I could find access through a struct. It's always numbered index into a byte array.
//-- Also note that throughout the code, the header is given as 10 bytes long and the payload
//   starts at index 10. The command starts at index 3 (FCF below). CRC is of payload only and
//   follows it (single uint8_t byte).
struct m4CommandHeader {
    uint16_t   start_str;           // 0x5555
    uint8_t    size;                // Len bytes, the data length, with len M3 generated
    uint16_t   FCF;                 // The frame control domain is shown in Table 2
    uint8_t    Type;                // Frame type, binding is set to a binding frame in Table 4
    uint16_t   PANID;               // Address? (Google says it's "Website address")
    uint16_t   NodeIDdest;          // The node address
    uint16_t   NodeIDsource;        // The node address
    uint8_t    command;
};

class M4SerialComm;
class QGCApplication;

//-----------------------------------------------------------------------------
//-- Accessor class to handle data structure in an "Yuneec" way
class m4Packet
{
public:
    m4Packet(QByteArray data_)
        : data(data_)
    {
    }
    int type()
    {
        return data[2] & 0xFF;
    }
    int commandID()
    {
        return data[9] & 0xFF;
    }
    int commandIdFromMission()
    {
        if(data.size() > 10)
            return data[10] & 0xff;
        else
            return 0;
    }
    int subCommandIDFromMission()
    {
        if(data.size() > 11)
            return data[11] & 0xff;
        else
            return 0;
    }
    QByteArray commandValues()
    {
        return data.mid(10); //-- Data - header = payload
    }
    int mixCommandId(int type, int commandId, int subCommandId)
    {
        if(type != Yuneec::COMMAND_TYPE_MISSION) {
            return commandId;
        } else {
            return type << 16 | commandId << 8 | subCommandId;
        }
    }
    int mixCommandId()
    {
        if(type() != Yuneec::COMMAND_TYPE_MISSION) {
            return commandID();
        } else {
            return mixCommandId(type(), commandIdFromMission(), subCommandIDFromMission());
        }
    }
    QByteArray data;
};

//-----------------------------------------------------------------------------
class RxBindInfo {
public:
    RxBindInfo()
        : mode(0)
        , panId(0)
        , nodeId(0)
        , aNum(0)
        , aBit(0)
        , swNum(0)
        , swBit(0)
        , txAddr(0)
    {
    }
    int mode;
    int panId;
    int nodeId;
    int aNum;
    int aBit;
    int swNum;
    int swBit;
    int txAddr;
    enum {
        TYPE_NULL   = -1,
        TYPE_SR12S  = 0,
        TYPE_SR12E  = 1,
        TYPE_SR24S  = 2,
        TYPE_RX24   = 3,
        TYPE_SR19P  = 4,
    };
    QString getName() {
        switch (mode) {
            case TYPE_SR12S:
                return QString("SR12S_%1").arg(nodeId);
            case TYPE_SR12E:
                return QString("SR12E_%1").arg(nodeId);
            case TYPE_SR24S:
                return QString("SR24S_%1 v1.03").arg(nodeId);
            case TYPE_RX24:
                return QString("RX24_%1").arg(nodeId);
            case TYPE_SR19P:
                return QString("SR19P_%1").arg(nodeId);
            default:
                if (mode >= 105) {
                    QString fmt;
                    fmt.sprintf("SR24S_%dv%.2f", nodeId, (float)mode / 100.0f);
                    return fmt;
                } else {
                    return QString::number(nodeId);
                }
        }
    }
};

//-----------------------------------------------------------------------------
class ControllerLocation {
public:
    ControllerLocation()
        : longitude(0.0)
        , latitude(0.0)
        , altitude(0.0)
        , satelliteCount(0)
        , accuracy(0.0f)
        , speed(0.0f)
        , angle(0.0f)
    {
    }
    ControllerLocation& operator=(ControllerLocation& other)
    {
        longitude       = other.longitude;
        latitude        = other.latitude;
        altitude        = other.altitude;
        satelliteCount  = other.satelliteCount;
        accuracy        = other.accuracy;
        speed           = other.speed;
        angle           = other.angle;
        return *this;
    }
    /**
     * Longitude of remote-controller
     */
    double longitude;
    /**
     * Latitude of remote-controller
     */
    double latitude;
    /**
     * Altitude of remote-controller
     */
    double altitude;
    /**
     * The number of satellite has searched
     */
    int satelliteCount;

    /**
     * Accuracy of remote-controller
     */
    float accuracy;

    /**
     * Speed of remote-controller
     */
    float speed;

    /**
     * Angle of remote-controller
     */
    float angle;
};

//-----------------------------------------------------------------------------
class QGCCustom : public QObject
{
    Q_OBJECT
public:
    QGCCustom(QObject* parent = NULL);
    ~QGCCustom();

    bool    init                    (QGCApplication* pApp);

    enum {
        M4_STATE_NONE           = 0,
        M4_STATE_AWAIT          = 1,
        M4_STATE_BIND           = 2,
        M4_STATE_CALIBRATION    = 3,
        M4_STATE_SETUP          = 4,
        M4_STATE_RUN            = 5,
        M4_STATE_SIM            = 6,
        M4_STATE_FACTORY_CALI   = 7
    };

    int     getm4State              () { return _m4State; }
    void    getControllerLocation   (ControllerLocation& location);

    static  uint8_t crc8            (uint8_t* buffer, int len);
    static  int     byteArrayToInt  (QByteArray data, int offset, bool isBigEndian = false);
    static  float   byteArrayToFloat(QByteArray data, int offset);
    static  short   byteArrayToShort(QByteArray data, int offset, bool isBigEndian = false);

private slots:
    void    _bytesReady             (QByteArray data);
    void    _stateManager           ();
private:
    bool    _enterRun               ();
    bool    _exitRun                ();
    bool    _startBind              ();
    bool    _enterBind              ();
    bool    _exitBind               ();
    bool    _bind                   (int rxAddr);
    bool    _unbind                 ();
    void    _checkExitRun           ();
    void    _initSequence           ();
    bool    _queryBindState         ();
    bool    _sendRecvBothCh         ();
    bool    _setChannelSetting      ();
    bool    _syncMixingDataDeleteAll();
    bool    _syncMixingDataAdd      ();
    bool    _sendRxResInfo          ();
    bool    _setPowerKey            (int function);
    void    _handleBindResponse     ();
    void    _handleQueryBindResponse(QByteArray data);
    bool    _handleNonTypePacket    (m4Packet& packet);
    void    _handleRxBindInfo       (m4Packet& packet);
    void    _handleChannel          (m4Packet& packet);
    bool    _handleCommand          (m4Packet& packet);
    void    _switchChanged          (m4Packet& packet);
    void    _handleMixedChannelData (m4Packet& packet);
    void    _handControllerFeedback (m4Packet& packet);
signals:
    void    m4StateChanged             (int state);
    void    switchStateChanged         (int swId, int oldState, int newState);
    void    channelDataStatus          (QByteArray channelData);
    void    controllerLocationChanged  ();
private:
    M4SerialComm* _commPort;
    enum {
        STATE_NONE,
        STATE_ENTER_BIND_ERROR,
        STATE_EXIT_RUN,
        STATE_ENTER_BIND,
        STATE_START_BIND,
        STATE_UNBIND,
        STATE_BIND,
        STATE_QUERY_BIND,
        STATE_EXIT_BIND,
        STATE_RECV_BOTH_CH,
        STATE_SET_CHANNEL_SETTINGS,
        STATE_MIX_CHANNEL_DELETE,
        STATE_MIX_CHANNEL_ADD,
        STATE_SEND_RX_INFO,
        STATE_ENTER_RUN,
        STATE_RUNNING
    };
    int                 _state;
    int                 _responseTryCount;
    int                 _currentChannelAdd;
    int                 _m4State;
    RxBindInfo          _rxBindInfoFeedback;
    QTimer              _timer;
    ControllerLocation  _controllerLocation;
};

//-----------------------------------------------------------------------------
class SwitchChanged {
public:
    /**
     * Hardware ID
     */
    int hwId;
    /**
     * Old status of hardware
     */
    int oldState;
    /**
     * New status of hardware
     */
    int newState;
};

#define m4CommandHeaderLen sizeof(m4CommandHeader)

//-----------------------------------------------------------------------------
// Base Yuneec Protocol Command
class m4Command
{
public:
    m4Command(int id, int type = Yuneec::COMMAND_TYPE_NORMAL)
    {
        data.fill(0, Yuneec::COMMAND_BODY_EXCLUDE_VALUES_LENGTH);
        data[2] = (uint8_t)type;
        data[9] = (uint8_t)id;
    }
    virtual ~m4Command() {}
    QByteArray pack(QByteArray payload = QByteArray())
    {
        if(payload.size()) {
            data.append(payload);
        }
        QByteArray command;
        command.resize(3);
        command[0] = 0x55;
        command[1] = 0x55;
        command[2] = (uint8_t)data.size() + 1;
        command.append(data);
        uint8_t crc = QGCCustom::crc8((uint8_t*)data.data(), data.size());
        command.append(crc);
        return command;
    }
    QByteArray data;
};

//-----------------------------------------------------------------------------
// Base Yuneec Protocol Message
class m4Message
{
public:
    m4Message(int id, int type = 0)
    {
        data.fill(0, 8);
        data[2] = (uint8_t)type;
        data[3] = (uint8_t)id;
    }
    virtual ~m4Message() {}
    QByteArray pack()
    {
        QByteArray command;
        command.resize(3);
        command[0] = 0x55;
        command[1] = 0x55;
        command[2] = (uint8_t)data.size() + 1;
        command.append(data);
        uint8_t crc = QGCCustom::crc8((uint8_t*)data.data(), data.size());
        command.append(crc);
        return command;
    }
    QByteArray data;
};

#endif
