import useData from "@/hooks/useData";
import { VehicleHudType } from "@/types/BasicTypes";
import classNames from "classnames";
import { useCallback, useEffect, useState } from "react";
import { useTranslation } from "react-i18next";

const TypeOfVehicleHud = () => {
  const { t } = useTranslation();
  const { onChangeOnOptions, HudStyle, setHudStyle } = useData();
  const [isSleep, setSleep] = useState<boolean>(false);

  useEffect(() => {
    if (!isSleep) return;
    setTimeout(() => {
      setSleep(false);
    }, 500);
  }, [isSleep]);

  const handleChangeBarType = useCallback(
    (type: VehicleHudType) => {
      const oldValue = HudStyle.vehicle_hud_style;
      if (isSleep || oldValue == type) return;
      setSleep(true);
      const newValue = type;
      onChangeOnOptions(`vehicle_hud_style`, oldValue, newValue);
      setHudStyle((p) => ({
        ...p,
        vehicle_hud_style: newValue,
      }));
    },
    [isSleep, HudStyle, setHudStyle, onChangeOnOptions]
  );

  const hudNames: { [key: VehicleHudType | number]: string } = {
    1: "classic_old",
    2: "time_bomb",
    3: "grt_one",
    4: "grt_two",
    5: "bmg",
    6: "gmg",
    7: "globe",
    8: "semi_circle",
    9: "hud_v2",
    10: "race_hud",
  };

  const backgroundColors = ["rgba(0, 194, 255, .3)", "rgba(163, 18, 52, .3)", "rgba(128, 174, 51, .3)", "rgba(1, 222, 167, .3)", "rgba(35, 129, 240, .3)"];

  return (
    <>
      <div className="p-1.5 overflow-auto scrollbar-hide" style={{ maxHeight: 280 }}>
        <div className="flex flex-col gap-1.5">
          {Object.entries(hudNames).map(([i, v]) => {
            const slot = parseInt(i) as VehicleHudType;
            const src = `images/vehicle_hud/v_${v}.png`;
            const backgroundColorIndex = (parseInt(i) - 1) % backgroundColors.length;
            const backgroundColor = backgroundColors[backgroundColorIndex];
            return (
              <button
                onClick={() => handleChangeBarType(slot)}
                key={i}
                className={classNames("rounded overflow-hidden relative flex py-1.5 px-3 justify-between items-center border border-212121", {
                  grayscale: HudStyle.vehicle_hud_style != slot,
                })}
                style={{
                  height: 66,
                  background: `linear-gradient(90deg, rgba(0, 0, 0, .3) 0%, ${backgroundColor} 100%)`,
                }}
              >
                <div className={classNames({ "scale-75 -translate-x-5": slot == 5 || slot == 8 })}>
                  <img className={classNames("h-14 w-full")} src={src} alt="vehicle_hud" />
                </div>
                <div>
                  <h1 className="uppercase font-bold text-sm">{t(v)} Series</h1>
                  <h1 className="uppercase font-bold text-xs text-white/25">Car Hud</h1>
                </div>
                <img className="absolute right-1" src="images/icons/typeof_veh_logo.svg" alt="typeof_veh_logo" />
              </button>
            );
          })}
        </div>
      </div>
    </>
  );
};

export default TypeOfVehicleHud;
