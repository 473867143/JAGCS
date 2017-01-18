#include "takeoff_mission_item.h"

using namespace domain;

TakeoffMissionItem::TakeoffMissionItem(Mission* mission, float pitch):
    DirectionMissionItem(mission, Takeoff, true),
    m_pitch(pitch)
{}

float TakeoffMissionItem::pitch() const
{
    return m_pitch;
}

void TakeoffMissionItem::setPitch(float pitch)
{
    if (qFuzzyCompare(m_pitch, pitch)) return;

    m_pitch = pitch;
    emit pitchChanged(pitch);
}
