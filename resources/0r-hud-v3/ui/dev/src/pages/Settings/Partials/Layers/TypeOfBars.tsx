import useData from "@/hooks/useData";
import { BarStyleType } from "@/types/BasicTypes";
import classNames from "classnames";
import { useCallback, useEffect, useState } from "react";
import { useTranslation } from "react-i18next";

const TypeOfBars = () => {
  const { t } = useTranslation();
  const { onChangeOnOptions, HudStyle, setHudStyle } = useData();
  const [isSleep, setSleep] = useState<boolean>(false);

  useEffect(() => {
    if (!isSleep) return;
    setTimeout(() => {
      setSleep(false);
    }, 500);
  }, [isSleep]);

  const Slots = ["circle", "zarg", "classic", "hexagon-w", "hexagon", "grt-premium", "square", "wave-c", "wave-h", "zarg-m", "universal"] as BarStyleType[];

  const handleChangeBarType = useCallback(
    (type: BarStyleType) => {
      const oldValue = HudStyle.bar_style;
      if (isSleep || oldValue == type) return;
      setSleep(true);
      const newValue = type;
      onChangeOnOptions(`bar_style`, oldValue, newValue);
      setHudStyle((p) => ({
        ...p,
        bar_style: newValue,
      }));
    },
    [isSleep, HudStyle, setHudStyle, onChangeOnOptions]
  );

  const backgroundColors = ["rgba(207, 78, 91, .3)", "rgba(255, 196, 0, .3)", "rgba(159, 255, 209, .3)", "rgba(196, 255, 72, .3)", "rgba(168, 136, 222, .5)", "rgba(255, 196, 0, .3)", "rgba(0, 194, 255, .3)", "rgba(196, 255, 72, .3)", "rgba(159, 255, 209, .3)", "rgba(207, 78, 91, .3)", "rgba(255, 196, 0, .3)"];

  return (
    <>
      <div className="p-1.5 overflow-auto scrollbar-hide" style={{ maxHeight: 280 }}>
        <div className="flex flex-col gap-1.5">
          {Slots.map((v, i) => {
            const backgroundColor = backgroundColors[i];
            return (
              <button
                onClick={() => handleChangeBarType(v)}
                key={i}
                className={classNames("rounded overflow-hidden relative flex py-1.5 px-3 justify-between items-center border border-212121", {
                  grayscale: HudStyle.bar_style != v,
                })}
                style={{
                  height: 66,
                  background: `linear-gradient(90deg, rgba(0, 0, 0, .3) 0%, ${backgroundColor} 100%)`,
                }}
              >
                <div>
                  <img className={classNames("h-10 w-full")} src={`images/icons/types_of_bar/${v}.svg`} alt="bar" />
                </div>
                <div>
                  <h1 className="uppercase font-bold text-sm">{t(v)} Series</h1>
                  <h1 className="uppercase font-bold text-xs text-white/25">Hud</h1>
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

export default TypeOfBars;
