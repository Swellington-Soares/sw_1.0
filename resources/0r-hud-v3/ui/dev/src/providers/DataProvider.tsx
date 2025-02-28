import React, { createContext, useEffect, useState } from "react";
import { useTranslation } from "react-i18next";
import { DataContextProps } from "@/types/DataProviderTypes";
import { useNuiEvent } from "@/hooks/useNuiEvent";
import {
  BarType,
  iBar,
  iCinematic,
  iClientInfo,
  iCompass,
  iHudStyle,
  iMiniMap,
  iMusicInfo,
  iNavigationWidget,
  iVehicleInfo,
} from "@/types/BasicTypes";
import { fetchNui } from "@/utils/fetchNui";
import "./debug.g";
import { BarColors } from "@/utils/misc";

export const DataCtx = createContext<DataContextProps>({} as DataContextProps);

export const DataProvider: React.FC<{ children: React.ReactNode }> = ({
  children,
}) => {
  const { i18n } = useTranslation();
  const [useableColors, setUseableColors] = useState<string[]>(BarColors);
  const [isEditorOpen, setEditorOpen] = useState<boolean>(false);
  const [isSettingsOpen, setSettingsOpen] = useState<boolean>(false);
  const [isHudReady, setHudReady] = useState<boolean>(false);
  const [ClientInfo, setClientInfo] = useState<iClientInfo>({
    active: true,
    positions: { x: undefined, y: undefined },
    radio: { active: true, show: true, inChannel: false, channel: 0 },
    player_source: { active: true, show: true, source: 1 },
    time: { active: true, show: true, gameHours: 0, gameMinutes: 0 },
    real_time: { active: true },
    server_info: {
      active: true,
      show: true,
      image: "index.png",
      name: "0Resmon",
      playerCount: 0,
      maxPlayers: 32,
    },
    cash: { active: true, show: true, amount: 0 },
    bank: { active: true, show: true, amount: 0 },
    extra_currency: { active: true, show: true, amount: 0 },
    job: { active: true, show: true, label: "Unemp", gradeLabel: "Unemp" },
    weapon: {
      active: true,
      show: true,
      name: "",
      ammo: { inClip: 0, inWeapon: 0 },
    },
  });
  const [MiniMap, setMiniMap] = useState<iMiniMap>({
    onlyInVehicle: true,
    style: "rectangle",
    editableByPlayers: true,
    mapPlacer: {},
  });
  const [Compass, setCompass] = useState<iCompass>({
    active: true,
    show: true,
    heading: 90,
    street1: "Street #1",
    street2: "Street #2",
    onlyInVehicle: true,
    editableByPlayers: true,
  });
  const [NavigationWidget, setNavigationWidget] = useState<iNavigationWidget>({
    positions: { x: undefined, y: undefined },
    active: true,
    show: true,
    navigation: {
      isDestinationActive: true,
      destinationStreet: "Route #1",
      currentStreet: "Street #1",
    },
  });
  const [MusicInfo, setMusicInfo] = useState<iMusicInfo>({
    active: true,
    isPlaying: false,
    songName: "0Resmon",
    songLabel: "0Resmon",
  });
  const [VehicleInfo, setVehicleInfo] = useState<iVehicleInfo>({
    positions: { x: undefined, y: undefined },
    entity: 0,
    currentGear: 0,
    engineHealth: 0,
    fuel: { level: 0, maxLevel: 100, type: "gasoline" },
    gearType: "auto",
    isBackLeftDoorOn: false,
    isBackRightDoorOn: false,
    isFrontLeftDoorOn: false,
    isFrontRightDoorOn: false,
    isHoodOn: false,
    isLightOn: false,
    isTrunkOn: false,
    kmH: true,
    rpm: 0,
    seatIndex: -1,
    speed: 0,
    isSeatbeltOn: false,
    veh_class: 1,
  });
  const [BarsInfo, setBarsInfo] = useState<Record<BarType, iBar>>({
    armor: { value: 100, autoHide: 100, color: "#1D4ED8" },
    health: { value: 100, autoHide: 100, color: "#CF4E5B" },
    hunger: { value: 100, autoHide: 100, color: "#FFC400" },
    oxygen: { value: 100, autoHide: 99, color: "#00FFA3" },
    stamina: { value: 100, autoHide: 100, color: "#C4FF48" },
    stress: { value: 0, autoHide: 100, color: "#6b21a8" },
    thirst: { value: 100, autoHide: 100, color: "#00C2FF" },
    vehicle_engine: { value: 0, autoHide: 99, color: "#C4FF48" },
    voice: {
      value: 100,
      autoHide: 100,
      color: "#FFFFFF",
      isTalking: false,
      talkRange: 2,
    },
    vehicle_nitro: { value: 0, autoHide: 99, color: "#CF654E" },
  });
  const [Cinematic, setCinematic] = useState<iCinematic>({
    active: true,
    show: false,
  });
  const [HudStyle, setHudStyle] = useState<iHudStyle>({
    bar_style: "hexagon-w",
    is_res_style_active: true,
    vehicle_hud_style: 4,
    positions: {
      bar_res_active: {},
      bar_default: {},
      bar_universal: {},
      settings: {},
      bar_zarg_m: {
        health: {},
        armor: {},
        hunger: {},
        stamina: {},
        stress: {},
        oxygen: {},
        voice: {},
        thirst: {},
      },
    },
    bar_size: 0,
  });
  useEffect(() => {
    fetchNui("nui:loadUI", true, true);
  }, []);
  useEffect(() => {
    fetchNui("nui:onMiniMapOnlyInVehicle", MiniMap.onlyInVehicle, true);
  }, [MiniMap.onlyInVehicle]);
  useEffect(() => {
    fetchNui("nui:onCompassOnlyInVehicle", Compass.onlyInVehicle, true);
  }, [Compass.onlyInVehicle]);
  useEffect(() => {
    fetchNui("nui:updateMiniMapStyle", MiniMap.style, true);
  }, [MiniMap.style]);
  useEffect(() => {
    fetchNui("nui:onChangeMiniMapPlacer", MiniMap.mapPlacer, true);
  }, [MiniMap.mapPlacer]);
  useEffect(() => {
    fetchNui("nui:onResStyleUpdate", HudStyle.is_res_style_active, true);
  }, [HudStyle.is_res_style_active]);
  useEffect(() => {
    fetchNui("nui:onBarStyleUpdate", HudStyle.bar_style, true);
  }, [HudStyle.bar_style]);

  useEffect(() => {
    fetchNui("nui:fixMiniMap", true, true);
  }, [
    MiniMap.style,
    MiniMap.mapPlacer,
    HudStyle.is_res_style_active,
    HudStyle.bar_style,
  ]);

  useNuiEvent("ui:setSettingsOpen", setSettingsOpen);
  useNuiEvent("ui:toggleCinematicMode", () => {
    const oldValue = Cinematic.show;
    setCinematic((p) => ({ ...p, show: !p.show }));
    fetchNui("ui:onChangeCinematicMode", !oldValue, true);
  });
  useNuiEvent("ui:resetHudPositions", () => {
    const hudComponents = [
      "client_info",
      "vehicle_info",
      "navigation_widget",
      "bar_res_active",
      "bar_default",
      "bar_universal",
      "settings",
    ];
    const resetHudPositions = (component: string) => {
      onChangeHudPositions(component, undefined, undefined);
    };

    hudComponents.forEach(resetHudPositions);
    onChangeHudPositions("bar_zarg_m_all", undefined, undefined, [
      "hunger",
      "health",
      "thirst",
      "armor",
      "stamina",
      "oxygen",
      "stress",
      "voice",
    ]);
  });

  useNuiEvent("ui:setHudData", (data) => {
    if (data.client_info) {
      setClientInfo((prevClientInfo) => ({
        ...prevClientInfo,
        bank: { ...prevClientInfo.bank, amount: data.client_info.bank.amount },
        cash: { ...prevClientInfo.cash, amount: data.client_info.cash.amount },
        extra_currency: {
          ...prevClientInfo.extra_currency,
          amount: data.client_info.extra_currency.amount,
        },
        job: {
          ...prevClientInfo.job,
          label: data.client_info.job.label,
          gradeLabel: data.client_info.job.gradeLabel,
        },
        player_source: {
          ...prevClientInfo.player_source,
          source: data.client_info.player_source.source,
        },
        radio: {
          ...prevClientInfo.radio,
          inChannel: data.client_info.radio.inChannel,
          channel: data.client_info.radio.channel,
        },
        time: {
          ...prevClientInfo.time,
          gameHours: data.client_info.time.gameHours,
          gameMinutes: data.client_info.time.gameMinutes,
        },
        weapon: {
          ...prevClientInfo.weapon,
          name: data.client_info.weapon.name,
          ammo: {
            inClip: data.client_info.weapon.ammo.inClip,
            inWeapon: data.client_info.weapon.ammo.inWeapon,
          },
        },
        server_info: {
          ...prevClientInfo.server_info,
          maxPlayers: data.client_info.server_info.maxPlayers,
          playerCount: data.client_info.server_info.playerCount,
        },
      }));
    }
    if (data.compass) {
      setCompass((prevCompass) => ({
        ...prevCompass,
        heading: data.compass.heading,
        street1: data.compass.street1,
        street2: data.compass.street2,
      }));
    }
    if (data.navigation_widget) {
      setNavigationWidget((prevNavigationWidget) => ({
        ...prevNavigationWidget,
        navigation: data.navigation_widget.navigation,
      }));
    }
    if (data.vehicle_info) {
      setVehicleInfo((prevVehicleInfo) => ({
        ...prevVehicleInfo,
        ...data.vehicle_info,
      }));
    }
    if (data.bars) {
      setBarsInfo((prevBarsInfo) => ({
        ...prevBarsInfo,
        armor: { ...prevBarsInfo.armor, value: data.bars.armor.value },
        health: { ...prevBarsInfo.health, value: data.bars.health.value },
        hunger: { ...prevBarsInfo.hunger, value: data.bars.hunger.value },
        oxygen: { ...prevBarsInfo.oxygen, value: data.bars.oxygen.value },
        stamina: { ...prevBarsInfo.stamina, value: data.bars.stamina.value },
        stress: { ...prevBarsInfo.stress, value: data.bars.stress.value },
        thirst: { ...prevBarsInfo.thirst, value: data.bars.thirst.value },
        vehicle_engine: {
          ...prevBarsInfo.vehicle_engine,
          value: data.bars.vehicle_engine.value,
        },
        vehicle_nitro: {
          ...prevBarsInfo.vehicle_nitro,
          value: data.bars.vehicle_nitro.value,
        },
        voice: {
          ...prevBarsInfo.voice,
          value: data.bars.voice.value,
          isTalking: data.bars.voice.isTalking,
          talkRange: data.bars.voice.talkRange,
        },
      }));
    }
  });

  useNuiEvent("ui:setupUI", (data) => {
    if (data.setLocale) {
      i18n.addResourceBundle("en", "translation", data.setLocale.data);
    }
    if (data.setDefaultSettings) {
      const def = data.setDefaultSettings;
      setHudStyle((prevHudStyle) => ({
        ...prevHudStyle,
        bar_style: def.bar_style,
        is_res_style_active: def.is_res_style_active,
        vehicle_hud_style: def.vehicle_hud_style,
      }));
      setMiniMap((prevMiniMap) => ({
        ...prevMiniMap,
        onlyInVehicle: def.mini_map.onlyInVehicle,
        style: def.mini_map.style,
        editableByPlayers: def.mini_map.editableByPlayers,
      }));
      setCompass((prevCompass) => ({
        ...prevCompass,
        active: def.compass.active,
        onlyInVehicle: def.compass.onlyInVehicle,
        editableByPlayers: def.compass.editableByPlayers,
      }));
      setCinematic((prevCinematic) => ({
        ...prevCinematic,
        active: def.cinematic.active,
      }));
      setVehicleInfo((prevVehicleInfo) => ({
        ...prevVehicleInfo,
        kmH: def.vehicle_info.kmH,
      }));
      setClientInfo((prevClientInfo) => ({
        ...prevClientInfo,
        active: def.client_info.active,
        server_info: {
          ...prevClientInfo.server_info,
          active: def.client_info.server_info.active,
          image: def.client_info.server_info.image,
          name: def.client_info.server_info.name,
        },
        bank: { ...prevClientInfo.bank, active: def.client_info.bank.active },
        cash: { ...prevClientInfo.cash, active: def.client_info.cash.active },
        extra_currency: {
          ...prevClientInfo.extra_currency,
          active: def.client_info.extra_currency.active,
        },
        job: { ...prevClientInfo.job, active: def.client_info.job.active },
        player_source: {
          ...prevClientInfo.player_source,
          active: def.client_info.player_source.active,
        },
        radio: {
          ...prevClientInfo.radio,
          active: def.client_info.radio.active,
        },
        real_time: {
          ...prevClientInfo.real_time,
          active: def.client_info.real_time.active,
        },
        time: { ...prevClientInfo.time, active: def.client_info.time.active },
        weapon: {
          ...prevClientInfo.weapon,
          active: def.client_info.weapon.active,
        },
      }));
      setNavigationWidget((prevNavigationWidget) => ({
        ...prevNavigationWidget,
        active: def.navigation_widget.active,
      }));
      setUseableColors(def.colors || []);
      setMusicInfo((prevMusicInfo) => ({
        ...prevMusicInfo,
        active: def.music_info.active,
      }));
      setBarsInfo((prevBarsInfo) => ({
        ...prevBarsInfo,
        armor: { ...prevBarsInfo.armor, color: def.bars.armor.color },
        health: { ...prevBarsInfo.health, color: def.bars.health.color },
        hunger: { ...prevBarsInfo.hunger, color: def.bars.hunger.color },
        oxygen: { ...prevBarsInfo.oxygen, color: def.bars.oxygen.color },
        stamina: { ...prevBarsInfo.stamina, color: def.bars.stamina.color },
        stress: { ...prevBarsInfo.stress, color: def.bars.stress.color },
        thirst: { ...prevBarsInfo.thirst, color: def.bars.thirst.color },
        vehicle_engine: {
          ...prevBarsInfo.vehicle_engine,
          color: def.bars.vehicle_engine.color,
        },
        vehicle_nitro: {
          ...prevBarsInfo.vehicle_nitro,
          color: def.bars.vehicle_nitro.color,
        },
        voice: { ...prevBarsInfo.voice, color: def.bars.voice.color },
      }));
    }
    setUpStorage();
    setHudReady(true);
    fetchNui("nui:onLoadUI", true, true);
  });

  useNuiEvent("ui:onMapPlacerEnd", (data) => {
    const mapPlacer = {} as any;
    mapPlacer[MiniMap.style] = data;
    setLocalStorage("map_placer", JSON.stringify(mapPlacer));
    setMiniMap((p) => ({
      ...p,
      mapPlacer: {
        ...p.mapPlacer,
        [p.style]: data,
      },
    }));
  });

  const getLocalStorage = (
    key: string,
    defaultValue?: any,
    parse?: boolean
  ) => {
    if (localStorage) {
      const item = localStorage.getItem(key);
      if (item == null) return defaultValue;
      if (parse) {
        return JSON.parse(item);
      }
      return item;
    }
    return defaultValue;
  };
  const setLocalStorage = (key: string, value: any) => {
    if (localStorage) {
      localStorage.setItem(key, value);
      return true;
    } else {
      return false;
    }
  };

  const setUpStorage = () => {
    setHudStyle((prevHudStyle) => ({
      ...prevHudStyle,
      is_res_style_active: getLocalStorage(
        "res_style",
        prevHudStyle.is_res_style_active,
        true
      ),
      bar_style: getLocalStorage("bar_style", prevHudStyle.bar_style),
      vehicle_hud_style: getLocalStorage(
        "vehicle_hud_style",
        prevHudStyle.vehicle_hud_style,
        true
      ),
      positions: {
        bar_res_active: getLocalStorage(
          "bar_res_active.positions",
          prevHudStyle.positions.bar_res_active,
          true
        ),
        bar_default: getLocalStorage(
          "bar_default.positions",
          prevHudStyle.positions.bar_default,
          true
        ),
        bar_universal: getLocalStorage(
          "bar_universal.positions",
          prevHudStyle.positions.bar_universal,
          true
        ),
        bar_zarg_m: getLocalStorage(
          "bar_zarg_m.positions",
          prevHudStyle.positions.bar_zarg_m,
          true
        ),
        settings: getLocalStorage(
          "settings.positions",
          prevHudStyle.positions.settings,
          true
        ),
      },
      bar_size: getLocalStorage("bar_size", prevHudStyle.bar_size, false),
    }));

    setMiniMap((prevMiniMap) => ({
      ...prevMiniMap,
      onlyInVehicle: prevMiniMap.editableByPlayers
        ? getLocalStorage(
            "mini_map.onlyInVehicle",
            prevMiniMap.onlyInVehicle,
            true
          )
        : prevMiniMap.onlyInVehicle,
      style: getLocalStorage("mini_map.style", prevMiniMap.style, false),
      mapPlacer: getLocalStorage("map_placer", {}, true),
    }));

    setCompass((prevCompass) => ({
      ...prevCompass,
      show: getLocalStorage("compass.show", true, true),
      onlyInVehicle: prevCompass.editableByPlayers
        ? getLocalStorage(
            "compass.onlyInVehicle",
            prevCompass.onlyInVehicle,
            true
          )
        : prevCompass.onlyInVehicle,
    }));

    setClientInfo((prevClientInfo) => ({
      ...prevClientInfo,
      bank: {
        ...prevClientInfo.bank,
        show: getLocalStorage("client_info.bank.show", true, true),
      },
      cash: {
        ...prevClientInfo.cash,
        show: getLocalStorage("client_info.cash.show", true, true),
      },
      extra_currency: {
        ...prevClientInfo.extra_currency,
        show: getLocalStorage("client_info.extra_currency.show", true, true),
      },
      job: {
        ...prevClientInfo.job,
        show: getLocalStorage("client_info.job.show", true, true),
      },
      player_source: {
        ...prevClientInfo.player_source,
        show: getLocalStorage("client_info.player_source.show", true, true),
      },
      radio: {
        ...prevClientInfo.radio,
        show: getLocalStorage("client_info.radio.show", true, true),
      },
      server_info: {
        ...prevClientInfo.server_info,
        show: getLocalStorage("client_info.server_info.show", true, true),
      },
      time: {
        ...prevClientInfo.time,
        show: getLocalStorage("client_info.time.show", true, true),
      },
      weapon: {
        ...prevClientInfo.weapon,
        show: getLocalStorage("client_info.weapon.show", true, true),
      },
      positions: {
        ...(prevClientInfo.positions || {}),
        ...getLocalStorage(
          "client_info.positions",
          { x: undefined, y: undefined },
          true
        ),
      },
    }));

    setNavigationWidget((prevNavigationWidget) => ({
      ...prevNavigationWidget,
      show: getLocalStorage("navigation_widget.show", true, true),
      positions: {
        ...(prevNavigationWidget.positions || {}),
        ...getLocalStorage(
          "navigation_widget.positions",
          { x: undefined, y: undefined },
          true
        ),
      },
    }));

    setBarsInfo((prevBarsInfo) => ({
      ...prevBarsInfo,
      armor: {
        ...prevBarsInfo.armor,
        ...getLocalStorage("armor", prevBarsInfo.armor, true),
      },
      health: {
        ...prevBarsInfo.health,
        ...getLocalStorage("health", prevBarsInfo.health, true),
      },
      hunger: {
        ...prevBarsInfo.hunger,
        ...getLocalStorage("hunger", prevBarsInfo.hunger, true),
      },
      oxygen: {
        ...prevBarsInfo.oxygen,
        ...getLocalStorage("oxygen", prevBarsInfo.oxygen, true),
      },
      stamina: {
        ...prevBarsInfo.stamina,
        ...getLocalStorage("stamina", prevBarsInfo.stamina, true),
      },
      stress: {
        ...prevBarsInfo.stress,
        ...getLocalStorage("stress", prevBarsInfo.stress, true),
      },
      thirst: {
        ...prevBarsInfo.thirst,
        ...getLocalStorage("thirst", prevBarsInfo.thirst, true),
      },
      vehicle_engine: {
        ...prevBarsInfo.vehicle_engine,
        ...getLocalStorage("vehicle_engine", prevBarsInfo.vehicle_engine, true),
      },
      voice: {
        ...prevBarsInfo.voice,
        ...getLocalStorage("voice", prevBarsInfo.voice, true),
      },
      vehicle_nitro: {
        ...prevBarsInfo.vehicle_nitro,
        ...getLocalStorage("vehicle_nitro", prevBarsInfo.vehicle_nitro, true),
      },
    }));

    setVehicleInfo((prevVehicleInfo) => ({
      ...prevVehicleInfo,
      positions: {
        ...(prevVehicleInfo.positions || {}),
        ...getLocalStorage(
          "vehicle_info.positions",
          { x: undefined, y: undefined },
          true
        ),
      },
    }));
  };

  const handleMiniMapStyleChange = (newValue: "circle" | "rectangle") => {
    onChangeOnOptions("mini_map.style", MiniMap.style, newValue);
    setMiniMap((prevMiniMap) => ({
      ...prevMiniMap,
      style: newValue,
    }));
  };

  const onChangeOnOptions = (key: string, oldValue: any, newValue: any) => {
    if (oldValue === newValue) return;
    setLocalStorage(key, newValue);
    const actions: { [key: string]: () => void } = {
      res_style: () => {
        if (HudStyle.bar_style === "zarg-m" && newValue === false) {
          handleMiniMapStyleChange("circle");
        }
      },
      bar_style: () => {
        if (newValue === "zarg-m" && !HudStyle.is_res_style_active) {
          handleMiniMapStyleChange("circle");
        }
      },
    };

    Object.keys(actions).forEach((actionKey) => {
      if (key.includes(actionKey)) {
        actions[actionKey]();
      }
    });
  };

  const onChangeBar = (key: BarType, bar: iBar) => {
    const newValue = {
      autoHide: bar.autoHide,
      style: bar.style,
      color: bar.color,
    };
    setLocalStorage(key, JSON.stringify(newValue));
  };

  const onChangeHudPositions = (
    key: string,
    x?: number,
    y?: number,
    subKey?: any
  ) => {
    let storageKey = key + ".positions";
    const newX = x ? x + 5 : x;
    const newY = y ? y + 15 : y;
    let positions = { x: newX, y: newY } as any;
    if (subKey) {
      if (key == "bar_zarg_m") {
        positions = {
          ...HudStyle.positions.bar_zarg_m,
          [subKey]: { x: newX, y: newY },
        };
      } else if (key == "bar_zarg_m_all") {
        storageKey = "bar_zarg_m.positions";
        positions = {};
        subKey.map((v: any) => {
          positions = {
            ...positions,
            [v]: { x: newX, y: newY },
          };
        });
      }
    }

    setLocalStorage(storageKey, JSON.stringify(positions));
    switch (key) {
      case "client_info":
        setClientInfo((p) => ({ ...p, positions: positions }));
        break;
      case "vehicle_info":
        setVehicleInfo((p) => ({ ...p, positions: positions }));
        break;
      case "navigation_widget":
        setNavigationWidget((p) => ({ ...p, positions: positions }));
        break;
      case "bar_res_active":
        setHudStyle((p) => ({
          ...p,
          positions: { ...p.positions, bar_res_active: positions },
        }));
        break;
      case "bar_default":
        setHudStyle((p) => ({
          ...p,
          positions: { ...p.positions, bar_default: positions },
        }));
        break;
      case "bar_universal":
        setHudStyle((p) => ({
          ...p,
          positions: { ...p.positions, bar_universal: positions },
        }));
        break;
      case "bar_zarg_m":
        setHudStyle((p) => ({
          ...p,
          positions: {
            ...p.positions,
            bar_zarg_m: {
              ...p.positions.bar_zarg_m,
              [subKey]: { ...positions[subKey] },
            },
          },
        }));
        break;
      case "bar_zarg_m_all":
        setHudStyle((p) => ({
          ...p,
          positions: {
            ...p.positions,
            bar_zarg_m: {
              ...p.positions.bar_zarg_m,
              ...positions,
            },
          },
        }));
        break;
      case "settings":
        setHudStyle((p) => ({
          ...p,
          positions: { ...p.positions, settings: positions },
        }));
        break;
    }
  };

  const value = {
    ClientInfo,
    setClientInfo,
    Compass,
    setCompass,
    MiniMap,
    setMiniMap,
    NavigationWidget,
    setNavigationWidget,
    MusicInfo,
    setMusicInfo,
    BarsInfo,
    setBarsInfo,
    Cinematic,
    setCinematic,
    HudStyle,
    setHudStyle,
    isHudReady,
    VehicleInfo,
    setVehicleInfo,
    onChangeOnOptions,
    onChangeBar,
    handleMiniMapStyleChange,
    onChangeHudPositions,
    isSettingsOpen,
    setSettingsOpen,
    isEditorOpen,
    setEditorOpen,
    useableColors,
  };

  return <DataCtx.Provider value={value}>{children}</DataCtx.Provider>;
};
