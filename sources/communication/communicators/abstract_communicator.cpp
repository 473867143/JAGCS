#include "abstract_communicator.h"

// Qt
#include <QTimerEvent>
#include <QDebug>

// Internal
#include "abstract_link.h"

namespace
{
    const int second = 1000;
}

using namespace comm;

AbstractCommunicator::AbstractCommunicator(QObject* parent):
    QObject(parent)
{
    qRegisterMetaType<Protocol>("Protocol");

    m_statisticsTimer = this->startTimer(::second);
}

QList<AbstractLink*> AbstractCommunicator::links() const
{
    return m_links;
}

void AbstractCommunicator::sendDataAllLinks(const QByteArray& data)
{
    for (AbstractLink* link: m_links)
    {
        if (link->isConnected()) link->sendData(data);
    }
}

void AbstractCommunicator::addLink(AbstractLink* link)
{
    m_links.append(link);

    connect(link, &AbstractLink::dataReceived,
            this, &AbstractCommunicator::onDataReceived);
    emit linkAdded(link);
}

void AbstractCommunicator::removeLink(AbstractLink* link)
{
    m_links.removeOne(link);

    disconnect(link, &AbstractLink::dataReceived,
               this, &AbstractCommunicator::onDataReceived);
    emit linkRemoved(link);
}

void AbstractCommunicator::timerEvent(QTimerEvent* event)
{
    if (event->timerId() != m_statisticsTimer) return QObject::timerEvent(event);

    for (AbstractLink* link: m_links)
    {
        emit linkStatisticsChanged(link,
                                   link->takeBytesReceived(),
                                   link->takeBytesSent());
    }
}
