export type ClientInfoType = "radio" | "player_source" | "time" | "server_info" | "cash" | "bank" | "job" | "weapon" | "extra_currency";

export type BarType = "hunger" | "health" | "thirst" | "armor" | "stamina" | "oxygen" | "stress" | "voice" | "vehicle_engine" | "vehicle_nitro";

export type BarStyleType = "circle" | "square" | "hexagon" | "hexagon-w" | "zarg" | "wave-c" | "wave-h" | "classic" | "universal" | "grt-premium" | "zarg-m";

export type BarProps = {
  occupancy: number;
  trackColor?: string;
  progressColor?: string;
  strokeWidth?: number;
  children?: React.ReactNode;
  [key: string]: any;
};

export type VehicleHudType = 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10;

export interface iClientInfo {
  active: boolean;
  positions: { x?: number; y?: number };
  radio: {
    active: boolean;
    show: boolean;
    inChannel: boolean;
    channel?: number;
  };
  player_source: {
    active: boolean;
    show: boolean;
    source: number;
  };
  time: {
    active: boolean;
    show: boolean;
    gameHours: number;
    gameMinutes: number;
  };
  real_time: {
    active: boolean;
  };
  server_info: {
    active: boolean;

    show: boolean;
    image: string;
    name: string;
    playerCount: number;
    maxPlayers: number;
  };
  cash: {
    active: boolean;
    show: boolean;
    amount: number;
  };
  bank: {
    active: boolean;
    show: boolean;
    amount: number;
  };
  extra_currency: {
    active: boolean;
    show: boolean;
    amount: number;
  };
  job: {
    active: boolean;
    show: boolean;
    label: string;
    gradeLabel: string;
  };
  weapon: {
    active: boolean;
    show: boolean;
    name: string;
    ammo: {
      inClip: number;
      inWeapon: number;
    };
  };
}

export interface iCompass {
  active: boolean;
  show: boolean;
  onlyInVehicle: boolean;
  heading: number;
  street1: string;
  street2: string;
  editableByPlayers: boolean;
}

export interface iNavigationWidget {
  positions: { x?: number; y?: number };
  active: boolean;
  show: boolean;
  navigation: {
    isDestinationActive: boolean;
    destinationStreet: string;
    currentStreet: string;
  };
}

export interface iMusicInfo {
  active: boolean;
  isPlaying: boolean;
  songName: string;
  songLabel: string;
  list?: {
    name: string;
    url: string;
  }[];
}

export interface iVehicleInfo {
  positions: { x?: number; y?: number };
  entity: number | undefined | false;
  kmH: boolean;
  speed: number;
  fuel: {
    level: number;
    maxLevel: number;
    type: "gasoline" | "electric";
  };
  currentGear: number | string;
  gearType: "auto" | "manual";
  rpm: number;
  engineHealth: number;
  seatIndex: number;
  isLightOn: boolean;
  isTrunkOn: boolean;
  isHoodOn: boolean;
  isBackRightDoorOn: boolean;
  isBackLeftDoorOn: boolean;
  isFrontRightDoorOn: boolean;
  isFrontLeftDoorOn: boolean;
  isSeatbeltOn: boolean;
  veh_class: number;
}

export interface iMiniMap {
  onlyInVehicle: boolean;
  style: "circle" | "rectangle";
  editableByPlayers: boolean;
  mapPlacer?: { circle?: any; rectangle?: any };
}

export interface iBar {
  value: number;
  autoHide?: number;
  style?: number;
  color?: string;
  [key: string]: any;
}

export interface iCinematic {
  active: boolean;
  show: boolean;
}

export type ZargMHudPositionsType = string | "hunger" | "health" | "thirst" | "armor" | "stamina" | "oxygen" | "stress" | "voice";

export interface iHudStyle {
  bar_style: BarStyleType;
  is_res_style_active: boolean;
  vehicle_hud_style: VehicleHudType;
  positions: {
    bar_res_active: { x?: number; y?: number };
    bar_default: { x?: number; y?: number };
    bar_universal: { x?: number; y?: number };
    bar_zarg_m: { [key: ZargMHudPositionsType]: { x?: number; y?: number } };
    settings: { x?: number; y?: number };
  };
  bar_size?: number;
}
