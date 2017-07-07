#include "communication_link_presenter.h"

// Qt
#include <QMap>
#include <QVariant>
#include <QSerialPortInfo>
#include <QDebug>

// Internal
#include "settings_provider.h"

#include "db_facade.h"
#include "link_description.h"\

#include "communication_service.h"

using namespace presentation;

CommunicationLinkPresenter::CommunicationLinkPresenter(
        db::DbFacade* dbFacade,
        domain::CommunicationService* service,
        const db::LinkDescriptionPtr& description,
        QObject* parent):
    BasePresenter(parent),
    m_dbFacade(dbFacade),
    m_service(service),
    m_description(description)
{}

db::LinkDescriptionPtr CommunicationLinkPresenter::description() const
{
    return m_description;
}

void CommunicationLinkPresenter::updateView()
{
    this->setViewProperty(PROPERTY(type), m_description->type());
    this->setViewProperty(PROPERTY(name), m_description->name());
    this->setViewProperty(PROPERTY(port), m_description->port());
    this->setViewProperty(PROPERTY(device), m_description->device());
    this->setViewProperty(PROPERTY(baudRate), m_description->baudRate());

    this->setViewProperty(PROPERTY(changed), false);
}

void CommunicationLinkPresenter::updateStatistics()
{
    this->setViewProperty(PROPERTY(connected), m_description->isConnected());
    this->invokeViewMethod(PROPERTY(updateStatistics),
                           m_description->bytesSentSec(),
                           m_description->bytesRecvSec());
}

void CommunicationLinkPresenter::setConnected(bool connected)
{
    m_service->setLinkConnected(m_description, connected);
}

void CommunicationLinkPresenter::save()
{
    m_description->setName(this->viewProperty(PROPERTY(name)).toString());
    m_description->setPort(this->viewProperty(PROPERTY(port)).toInt());
    m_description->setDevice(this->viewProperty(PROPERTY(device)).toString());
    m_description->setBaudRate(this->viewProperty(PROPERTY(baudRate)).toInt());

    if (!m_dbFacade->save(m_description)) return;

    this->setViewProperty(PROPERTY(changed), false);
}

void CommunicationLinkPresenter::remove()
{
    m_dbFacade->remove(m_description);
}

void CommunicationLinkPresenter::connectView(QObject* view)
{
    QStringList devices;
    devices.append(QString());
    for (const QSerialPortInfo& info: QSerialPortInfo::availablePorts())
        devices.append(info.portName());
    this->setViewProperty(PROPERTY(devices), devices);

    QVariantList baudRates;
    for (qint32 rate: QSerialPortInfo::standardBaudRates())
        baudRates.append(rate);
    this->setViewProperty(PROPERTY(baudRates), baudRates);

    this->setViewProperty(PROPERTY(statisticsCount), settings::Provider::value(
                              settings::communication::statisticsCount));

    connect(view, SIGNAL(save()), this, SLOT(save()));
    connect(view, SIGNAL(restore()), this, SLOT(updateView()));
    connect(view, SIGNAL(remove()), this, SLOT(remove()));
    connect(view, SIGNAL(setConnected(bool)), this, SLOT(setConnected(bool)));

    this->updateView();
}
