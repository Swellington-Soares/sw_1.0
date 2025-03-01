import React from "react";
import { hunger_1, hunger_2, hunger_3, hunger_4 } from "./Partials/Hunger";
import { health_1, health_2, health_3, health_4, health_Zarg } from "./Partials/Health";
import { armor_1, armor_2, armor_3, armor_4 } from "./Partials/Armor";
import { oxygen_1, oxygen_2, oxygen_3, oxygen_4 } from "./Partials/Oxygen";
import { stamina_1, stamina_2, stamina_3, stamina_4 } from "./Partials/Stamina";
import { stress_1, stress_2, stress_3, stress_4 } from "./Partials/Stress";
import { vehicle_engine_1, vehicle_engine_2, vehicle_engine_3, vehicle_engine_4 } from "./Partials/VehicleEngine";
import { voice_1, voice_2 } from "./Partials/Voice";
import { thirst_1, thirst_2, thirst_3, thirst_4 } from "./Partials/Thirts";
import { nitro_1 } from "./Partials/Nitro";

interface IconProps {
  iconReq: string;
  color?: string;
  opacity?: number;
  size?: string;
}

const iconMap: { [key: string]: JSX.Element } = {
  "hunger.1": hunger_1,
  "hunger.2": hunger_2,
  "hunger.3": hunger_3,
  "hunger.4": hunger_4,
  "health.1": health_1,
  "health.2": health_2,
  "health.3": health_3,
  "health.4": health_4,
  "armor.1": armor_1,
  "armor.2": armor_2,
  "armor.3": armor_3,
  "armor.4": armor_4,
  "oxygen.1": oxygen_1,
  "oxygen.2": oxygen_2,
  "oxygen.3": oxygen_3,
  "oxygen.4": oxygen_4,
  "stamina.1": stamina_1,
  "stamina.2": stamina_2,
  "stamina.3": stamina_3,
  "stamina.4": stamina_4,
  "stress.1": stress_1,
  "stress.2": stress_2,
  "stress.3": stress_3,
  "stress.4": stress_4,
  "voice.1": voice_1,
  "voice.2": voice_2,
  "thirst.1": thirst_1,
  "thirst.2": thirst_2,
  "thirst.3": thirst_3,
  "thirst.4": thirst_4,
  zarg_health_armor: health_Zarg,
  "vehicle_nitro.1": nitro_1,
  "vehicle_engine.1": vehicle_engine_1,
  "vehicle_engine.2": vehicle_engine_2,
  "vehicle_engine.3": vehicle_engine_3,
  "vehicle_engine.4": vehicle_engine_4,
};

const Icon: React.FC<IconProps> = ({ iconReq, color = "#CF4E5B", size = "40%", opacity = 1.0 }) => {
  const IconComponent = iconMap[iconReq];
  if (!IconComponent) {
    return <></>;
  }
  return React.cloneElement(IconComponent, {
    style: { fill: color, fillOpacity: opacity, width: size, height: size },
  });
};

export default Icon;
