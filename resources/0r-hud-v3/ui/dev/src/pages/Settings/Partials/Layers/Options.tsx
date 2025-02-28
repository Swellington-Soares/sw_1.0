import useData from "@/hooks/useData";
import { ClientInfoType } from "@/types/BasicTypes";
import classNames from "classnames";
import React, { useCallback, useEffect, useState } from "react";
import { useTranslation } from "react-i18next";
import { FaCircleInfo, FaCompass } from "react-icons/fa6";
import { HiMiniMap } from "react-icons/hi2";
import { BsBorderStyle } from "react-icons/bs";
import { MdMovieFilter } from "react-icons/md";
import { FaLocationCrosshairs } from "react-icons/fa6";
import { IoMove } from "react-icons/io5";
import { fetchNui } from "@/utils/fetchNui";
import { IoIosResize } from "react-icons/io";
import { GrPowerReset } from "react-icons/gr";

interface iShowValueOpt {
  active: boolean;
  icon: string | React.ReactNode;
  label: string;
  value: boolean;
  onChange: () => void;
}
type MapType = "circle" | "rectangle";

const Options = () => {
  const { t } = useTranslation();
  const {
    isEditorOpen,
    setEditorOpen,
    onChangeOnOptions,
    setMiniMap,
    MiniMap,
    setClientInfo,
    ClientInfo,
    setCompass,
    Compass,
    NavigationWidget,
    setNavigationWidget,
    HudStyle,
    setHudStyle,
    Cinematic,
    setCinematic,
    handleMiniMapStyleChange,
    onChangeHudPositions,
  } = useData();
  const [isSleep, setSleep] = useState<boolean>(false);
  const [hudBarSize, setBarSize] = useState<number>(HudStyle.bar_size || 0);

  useEffect(() => {
    if (!isSleep) return;
    setTimeout(() => {
      setSleep(false);
    }, 500);
  }, [isSleep]);

  const handleChangeMapStyle = useCallback(
    async (style: MapType) => {
      if (isSleep) return;
      if (HudStyle.bar_style === "zarg-m" && !HudStyle.is_res_style_active)
        return;

      try {
        handleMiniMapStyleChange(style);
      } catch (error) {
        console.error("Error while setting map style: ", error);
      } finally {
        setSleep(true);
      }
    },
    [isSleep, HudStyle, setSleep, handleMiniMapStyleChange]
  );

  const toggleClientInfoShowValue = useCallback(
    (key: ClientInfoType) => {
      if (isSleep) return;
      setSleep(true);
      const oldValue = ClientInfo[key].show;
      onChangeOnOptions(`client_info.${key}.show`, oldValue, !oldValue);
      setClientInfo((p) => ({
        ...p,
        [key]: {
          ...p[key],
          show: !p[key].show,
        },
      }));
    },
    [isSleep, ClientInfo, setClientInfo, onChangeOnOptions]
  );

  const toggleNavigationWidgetShowValue = useCallback(() => {
    if (isSleep) return;
    setSleep(true);
    const oldValue = NavigationWidget.show;
    onChangeOnOptions("navigation_widget.show", oldValue, !oldValue);
    setNavigationWidget((p) => ({
      ...p,
      show: !p.show,
    }));
  }, [isSleep, NavigationWidget, setNavigationWidget, onChangeOnOptions]);

  const toggleCompassShowValue = useCallback(() => {
    if (isSleep) return;
    setSleep(true);
    const oldValue = Compass.show;
    onChangeOnOptions("compass.show", oldValue, !oldValue);
    setCompass((p) => ({
      ...p,
      show: !p.show,
    }));
  }, [isSleep, Compass, setCompass, onChangeOnOptions]);

  const toggleCompassOnlyInVehicle = useCallback(() => {
    if (isSleep) return;
    setSleep(true);
    const oldValue = Compass.onlyInVehicle;
    onChangeOnOptions("compass.onlyInVehicle", oldValue, !oldValue);
    setCompass((p) => ({
      ...p,
      onlyInVehicle: !p.onlyInVehicle,
    }));
  }, [isSleep, Compass, setCompass, onChangeOnOptions]);

  const toggleMiniMapOnlyInVehicle = useCallback(() => {
    if (isSleep) return;
    setSleep(true);
    const oldValue = MiniMap.onlyInVehicle;
    onChangeOnOptions("mini_map.onlyInVehicle", oldValue, !oldValue);
    setMiniMap((p) => ({
      ...p,
      onlyInVehicle: !p.onlyInVehicle,
    }));
  }, [isSleep, MiniMap, setMiniMap, onChangeOnOptions]);

  const toggleResStyle = useCallback(() => {
    if (isSleep) return;
    setSleep(true);
    const oldValue = HudStyle.is_res_style_active;
    onChangeOnOptions("res_style", oldValue, !oldValue);
    setHudStyle((p) => ({
      ...p,
      is_res_style_active: !p.is_res_style_active,
    }));
  }, [isSleep, HudStyle, setHudStyle, onChangeOnOptions]);

  const handleToggleCinematic = () => {
    const oldValue = Cinematic.show;
    setCinematic((p) => ({ ...p, show: !p.show }));
    fetchNui("ui:onChangeCinematicMode", !oldValue, true);
  };

  const handleChangeBarSize = (e: React.ChangeEvent<HTMLInputElement>) => {
    e.preventDefault();
    const newValue = Math.max(0, parseInt(e.currentTarget?.value || "0"));
    setBarSize(newValue);
    const oldValue = HudStyle.bar_size;
    setHudStyle((p) => ({ ...p, bar_size: newValue }));
    onChangeOnOptions("bar_size", oldValue, newValue);
  };

  const ShowValueOptions: iShowValueOpt[] = [
    {
      active: NavigationWidget.active,
      icon: "images/icons/navigation.svg",
      label: t("navigation_widget"),
      value: NavigationWidget.show,
      onChange: () => toggleNavigationWidgetShowValue(),
    },
    {
      active: ClientInfo.active && ClientInfo.player_source.active,
      icon: "images/icons/user.svg",
      label: t("user_id"),
      value: ClientInfo.player_source.show,
      onChange: () => toggleClientInfoShowValue("player_source"),
    },
    {
      active: ClientInfo.active && ClientInfo.job.active,
      icon: "images/icons/job_bag.svg",
      label: t("current_job"),
      value: ClientInfo.job.show,
      onChange: () => toggleClientInfoShowValue("job"),
    },
    {
      active: ClientInfo.active && ClientInfo.cash.active,
      icon: "images/icons/coin.svg",
      label: t("cash"),
      value: ClientInfo.cash.show,
      onChange: () => toggleClientInfoShowValue("cash"),
    },
    {
      active: ClientInfo.active && ClientInfo.bank.active,
      icon: "images/icons/bank.svg",
      label: t("bank"),
      value: ClientInfo.bank.show,
      onChange: () => toggleClientInfoShowValue("bank"),
    },
    {
      active: ClientInfo.active && ClientInfo.extra_currency.active,
      icon: "images/icons/coin.svg",
      label: t("other_currency"),
      value: ClientInfo.extra_currency.show,
      onChange: () => toggleClientInfoShowValue("extra_currency"),
    },
    {
      active: ClientInfo.active && ClientInfo.radio.active,
      icon: "images/icons/radio.svg",
      label: t("radio"),
      value: ClientInfo.radio.show,
      onChange: () => toggleClientInfoShowValue("radio"),
    },
    {
      active: ClientInfo.active && ClientInfo.time.active,
      icon: "images/icons/time_morning.svg",
      label: t("time"),
      value: ClientInfo.time.show,
      onChange: () => toggleClientInfoShowValue("time"),
    },
    {
      active: ClientInfo.active && ClientInfo.weapon.active,
      icon: "images/icons/weapon.svg",
      label: t("weapon"),
      value: ClientInfo.weapon.show,
      onChange: () => toggleClientInfoShowValue("weapon"),
    },
    {
      active: ClientInfo.active && ClientInfo.server_info.active,
      icon: <FaCircleInfo />,
      label: t("server_info"),
      value: ClientInfo.server_info.show,
      onChange: () => toggleClientInfoShowValue("server_info"),
    },
    {
      active: Compass.active,
      icon: <FaCompass />,
      label: t("compass"),
      value: Compass.show,
      onChange: () => toggleCompassShowValue(),
    },
  ];

  const handleResetPositions = () => {
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
  };

  const handleResetAll = () => {
    if (isSleep) return;
    setSleep(true);
    localStorage.clear();
    setMiniMap((p) => ({
      ...p,
      mapPlacer: {},
    }));
  };

  const handleEditMiniMap = () => {
    fetchNui("ui:OpenEditMiniMap", true, true);
  };

  const handleResetMiniMap = () => {
    localStorage.setItem("map_placer", JSON.stringify({}));
    setMiniMap((p) => ({
      ...p,
      mapPlacer: {},
    }));
  };

  return (
    <>
      <div
        className="p-2.5 flex flex-col gap-1.5 overflow-auto scrollbar-hide"
        style={{ maxHeight: 280 }}
      >
        <div id="change-style-res">
          <div className="flex gap-1.5 items-center select-none">
            <div className="min-w-8 min-h-8 p-1 rounded border border-white/15 bg-white/20 flex items-center justify-center">
              <BsBorderStyle className="w-full h-full" />
            </div>
            <div className="relative flex w-full items-center">
              <div className="w-full min-h-8 rounded border border-white/10 bg-white/10 flex items-center pl-2.5">
                <h1 className="text-white text-xs font-bold">
                  {t("res_style_seq")}
                </h1>
              </div>
              <div className="absolute right-1">
                <label className="setting-switch outline-none ring-0">
                  <input
                    type="checkbox"
                    checked={HudStyle.is_res_style_active}
                    onChange={toggleResStyle}
                  />
                </label>
              </div>
            </div>
          </div>
        </div>
        <div id="change-mini-map">
          <div className="flex gap-1.5 items-center select-none">
            <div className="relative max-w-8 min-w-8 max-h-8 min-h-8 rounded border border-white/15 bg-white/20 flex items-center justify-center">
              <div
                className={classNames(
                  "absolute inset-0 border-2 border-white/40 bg-contain m-0.5",
                  {
                    rounded: MiniMap.style == "rectangle",
                    "rounded-full": MiniMap.style == "circle",
                  }
                )}
                style={{ backgroundImage: "url(images/core/gtav_atlas.png)" }}
              ></div>
            </div>
            <div className="relative flex w-full items-center">
              <div className="w-full min-h-8 rounded border border-white/10 bg-white/10 flex items-center pl-2.5">
                <h1 className="text-white text-xs font-bold">
                  {t("map_type")}
                </h1>
              </div>
              <div className="absolute right-1">
                <div className="flex items-center gap-2">
                  <button
                    onClick={() => handleChangeMapStyle("circle")}
                    className={classNames(
                      "min-w-6 min-h-6",
                      "bg-contain rounded-full",
                      "border-2 border-white/50 hover:border-red-white/25",
                      {
                        "!border-transparent": MiniMap.style != "circle",
                      }
                    )}
                    style={{
                      backgroundImage: "url(images/core/gtav_atlas.png)",
                    }}
                  ></button>
                  <button
                    onClick={() => handleChangeMapStyle("rectangle")}
                    className={classNames(
                      "min-w-6 min-h-6",
                      "bg-contain rounded",
                      "border-2 border-white/50 hover:border-red-white/25",
                      {
                        "!border-transparent": MiniMap.style != "rectangle",
                      }
                    )}
                    style={{
                      backgroundImage: "url(images/core/gtav_atlas.png)",
                    }}
                  ></button>
                </div>
              </div>
            </div>
          </div>
        </div>
        <hr className="border-white/10" />
        {ShowValueOptions.map(
          (opt, i) =>
            opt.active && (
              <div key={i} className="flex gap-1.5 items-center select-none">
                <div className="min-w-8 min-h-8 max-w-8 max-h-8 rounded border border-white/15 bg-white/20 flex items-center justify-center">
                  {typeof opt.icon == "string" ? (
                    <img className="w-5 h-5" src={opt.icon} alt="opt-icon" />
                  ) : (
                    opt.icon
                  )}
                </div>
                <div className="relative flex w-full items-center">
                  <div className="w-full min-h-8 rounded border border-white/10 bg-white/10 flex items-center pl-2.5">
                    <h1 className="text-white text-xs font-bold">
                      {opt.label}
                    </h1>
                  </div>
                  <div className="absolute right-1">
                    <label className="setting-switch outline-none ring-0">
                      <input
                        type="checkbox"
                        checked={opt.value}
                        onChange={opt.onChange}
                      />
                    </label>
                  </div>
                </div>
              </div>
            )
        )}
        <hr className="border-white/10" />
        {Compass.active && Compass.editableByPlayers && (
          <div className="flex gap-1.5 items-center select-none">
            <div className="min-w-8 min-h-8 rounded border border-white/15 bg-white/20 flex items-center justify-center">
              <FaCompass />
            </div>
            <div className="relative flex w-full items-center">
              <div className="w-full min-h-8 rounded border border-white/10 bg-white/10 flex items-center pl-2.5">
                <h1 className="text-white text-xs font-bold">
                  {t("compass_only_vehicle")}
                </h1>
              </div>
              <div className="absolute right-1">
                <label className="setting-switch outline-none ring-0">
                  <input
                    type="checkbox"
                    checked={Compass.onlyInVehicle}
                    onChange={toggleCompassOnlyInVehicle}
                  />
                </label>
              </div>
            </div>
          </div>
        )}
        {MiniMap.editableByPlayers && (
          <div className="flex gap-1.5 items-center select-none">
            <div className="min-w-8 min-h-8 rounded border border-white/15 bg-white/20 flex items-center justify-center">
              <HiMiniMap />
            </div>
            <div className="relative flex w-full items-center">
              <div className="w-full min-h-8 rounded border border-white/10 bg-white/10 flex items-center pl-2.5">
                <h1 className="text-white text-xs font-bold">
                  {t("minimap_only_vehicle")}
                </h1>
              </div>
              <div className="absolute right-1">
                <label className="setting-switch outline-none ring-0">
                  <input
                    type="checkbox"
                    checked={MiniMap.onlyInVehicle}
                    onChange={toggleMiniMapOnlyInVehicle}
                  />
                </label>
              </div>
            </div>
          </div>
        )}
        {Cinematic.active && (
          <div className="flex gap-1.5 items-center select-none">
            <div className="min-w-8 min-h-8 rounded border border-white/15 bg-white/20 flex items-center justify-center">
              <MdMovieFilter />
            </div>
            <div className="relative flex w-full items-center">
              <div className="w-full min-h-8 rounded border border-white/10 bg-white/10 flex items-center pl-2.5">
                <h1 className="text-white text-xs font-bold">
                  {t("movie_bars")}
                </h1>
              </div>
              <div className="absolute right-1">
                <label className="setting-switch outline-none ring-0">
                  <input
                    type="checkbox"
                    checked={Cinematic.show}
                    onChange={handleToggleCinematic}
                  />
                </label>
              </div>
            </div>
          </div>
        )}
        <div className="flex gap-1.5 items-center select-none">
          <div className="min-w-8 min-h-8 rounded border border-white/15 bg-white/20 flex items-center justify-center">
            <IoMove />
          </div>
          <div className="relative flex w-full items-center">
            <div className="w-full min-h-8 rounded border border-white/10 bg-white/10 flex items-center pl-2.5">
              <h1 className="text-white text-xs font-bold">
                {t("editor_mode")}
              </h1>
              <div className="absolute right-1">
                <label className="setting-switch outline-none ring-0">
                  <input
                    type="checkbox"
                    checked={isEditorOpen}
                    onChange={() => setEditorOpen((p) => !p)}
                  />
                </label>
              </div>
            </div>
          </div>
        </div>
        <div className="flex gap-1.5 items-center select-none">
          <div className="min-w-8 min-h-8 rounded border border-white/15 bg-white/20 flex items-center justify-center">
            <FaLocationCrosshairs />
          </div>
          <div className="relative flex w-full items-center">
            <div className="w-full min-h-8 rounded border border-white/10 bg-white/10 flex items-center pl-2.5">
              <h1 className="text-white text-xs font-bold">
                {t("reset_all_positions")}
              </h1>
              <div className="ml-auto flex items-center justify-center px-1">
                <button
                  onClick={handleResetPositions}
                  className="w-5 h-5 bg-121212 border border-white/10 rounded-full hover:bg-FF013D transition-colors"
                ></button>
              </div>
            </div>
          </div>
        </div>
        <div className="flex gap-1.5 items-center select-none">
          <div className="min-w-8 min-h-8 rounded border border-white/15 bg-white/20 flex items-center justify-center">
            <IoIosResize />
          </div>
          <div className="relative flex w-full items-center">
            <div className="w-full min-h-8 rounded border border-white/10 bg-white/10 flex items-center pl-2.5">
              <h1 className="text-white text-xs font-bold">
                {t("bar_default_size")}
              </h1>
              <div className="ml-auto flex items-center justify-center px-1">
                <input
                  onChange={handleChangeBarSize}
                  value={hudBarSize}
                  type="number"
                  id="bar_size"
                  className="h-full w-14 p-1 bg-121212 border border-white/10 rounded text-xs outline-none ring-0"
                />
              </div>
            </div>
          </div>
        </div>
        <hr className="border-white/10" />
        <div className="flex gap-1.5 items-center select-none">
          <div className="min-w-8 min-h-8 rounded border border-white/15 bg-white/20 flex items-center justify-center">
            <IoMove />
          </div>
          <div className="relative flex w-full items-center">
            <div className="w-full min-h-8 rounded border border-white/10 bg-white/10 flex items-center pl-2.5">
              <h1 className="text-white text-xs font-bold">
                {t("edit_mini_map")}
              </h1>
              <div className="ml-auto flex items-center justify-center px-1">
                <button
                  onClick={handleEditMiniMap}
                  className="w-5 h-5 bg-121212 border border-white/10 rounded-full hover:bg-01DEA7 transition-colors"
                ></button>
              </div>
            </div>
          </div>
        </div>
        <div className="flex gap-1.5 items-center select-none">
          <div className="min-w-8 min-h-8 rounded border border-white/15 bg-white/20 flex items-center justify-center">
            <IoMove />
          </div>
          <div className="relative flex w-full items-center">
            <div className="w-full min-h-8 rounded border border-white/10 bg-white/10 flex items-center pl-2.5">
              <h1 className="text-white text-xs font-bold">
                {t("reset_mini_map")}
              </h1>
              <div className="ml-auto flex items-center justify-center px-1">
                <button
                  onClick={handleResetMiniMap}
                  className="w-5 h-5 bg-121212 border border-white/10 rounded-full hover:bg-01DEA7 transition-colors"
                ></button>
              </div>
            </div>
          </div>
        </div>
        <hr className="border-white/10" />
        <div className="flex gap-1.5 items-center select-none">
          <div className="min-w-8 min-h-8 rounded border border-white/15 bg-white/20 flex items-center justify-center">
            <GrPowerReset />
          </div>
          <div className="relative flex w-full items-center">
            <div className="w-full min-h-8 rounded border border-white/10 bg-white/10 flex items-center pl-2.5">
              <h1 className="text-white text-xs font-bold">
                {t("clear_cache")}
              </h1>
              <div className="ml-auto flex items-center justify-center px-1">
                <button
                  onClick={handleResetAll}
                  className="w-5 h-5 bg-121212 border border-white/10 rounded-full hover:bg-FF013D transition-colors"
                ></button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </>
  );
};
export default Options;
