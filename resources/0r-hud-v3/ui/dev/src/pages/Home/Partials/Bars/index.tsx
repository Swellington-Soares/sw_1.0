import Icon from "@/components/Icon";
import ProgressBar from "@/components/Progressbar/ProgressBar";
import useData from "@/hooks/useData";
import { BarStyleType, BarType, ZargMHudPositionsType } from "@/types/BasicTypes";
import { calcIconColor, VOICE_TALKING_COLOR } from "@/utils/misc";
import classNames from "classnames";
import { DragDropContainer } from "react-drag-drop-container-typescript";
import { FaLocationCrosshairs } from "react-icons/fa6";

const Bars: BarType[] = ["voice", "health", "armor", "hunger", "thirst", "stamina", "oxygen", "stress", "vehicle_engine", "vehicle_nitro"];

const getProgressBarProps = (bar: any, barStyle: string) => ({
  occupancy: bar?.value,
  progressColor: bar?.color,
  shape: (barStyle === "zarg-m" ? "zarg" : barStyle) as BarStyleType,
});

const getIconColor = (barStyle: BarStyleType, color?: string, meta?: any) => {
  return calcIconColor(barStyle, color, meta);
};

const BarIcon = ({ slot, bar, barStyle }: { slot: BarType; bar: any; barStyle: BarStyleType }) => (
  <ProgressBar {...getProgressBarProps(bar, barStyle)}>
    <Icon iconReq={`${slot}.${bar?.style || 1}`} color={getIconColor(barStyle, bar.color, bar)} />
  </ProgressBar>
);

export const BarsComponent = () => {
  const { BarsInfo, HudStyle, VehicleInfo, onChangeHudPositions, isEditorOpen, ClientInfo } = useData();

  const handleDragEnd = (key: string, x: number, y: number, subKey?: string) => {
    onChangeHudPositions(key, x, y, subKey);
  };

  const _positions = {
    bar_res_active: {} as any,
    bar_default: {} as any,
    bar_universal: {} as any,
    bar_zarg_m: { health: {}, armor: {}, stamina: {}, stress: {}, oxygen: {}, voice: {}, hunger: {}, thirst: {} } as any,
  };
  // Positions bar_res_active
  _positions.bar_res_active.left = HudStyle.positions.bar_res_active.x || 16;
  if (HudStyle.positions.bar_res_active.y) {
    _positions.bar_res_active.top = HudStyle.positions.bar_res_active.y;
  } else {
    _positions.bar_res_active.bottom = 16;
  }
  // Positions bar_default
  _positions.bar_default.left = HudStyle.positions.bar_default.x || 16;
  if (HudStyle.positions.bar_default.y) {
    _positions.bar_default.top = HudStyle.positions.bar_default.y;
  } else {
    _positions.bar_default.bottom = 24;
  }
  // Positions bar_universal
  _positions.bar_universal.left = HudStyle.positions.bar_universal.x || 16;
  if (HudStyle.positions.bar_universal.y) {
    _positions.bar_universal.top = HudStyle.positions.bar_universal.y;
  } else {
    _positions.bar_universal.bottom = 24;
  }

  const calcZargmPosition = (key: ZargMHudPositionsType) => {
    const pos = {} as any;
    if (HudStyle.positions.bar_zarg_m[key]?.x && HudStyle.positions.bar_zarg_m[key]?.y) {
      pos.left = HudStyle.positions.bar_zarg_m[key]?.x || 0;
      pos.top = HudStyle.positions.bar_zarg_m[key].y || 0;
    } else {
      if (key == "voice") {
        pos.left = 195;
        pos.bottom = 32;
      } else if (key == "hunger") {
        pos.left = 227;
        pos.bottom = 65;
      } else if (key == "thirst") {
        pos.left = 250;
        pos.bottom = 104;
      } else if (key == "stamina") {
        pos.left = 195;
        pos.bottom = 240;
      } else if (key == "stress") {
        pos.left = 227;
        pos.bottom = 210;
      } else if (key == "oxygen") {
        pos.left = 250;
        pos.bottom = 170;
      } else if (key == "health") {
        pos.left = 2;
        pos.bottom = 16;
      } else if (key == "armor") {
        pos.left = 2;
        pos.bottom = 38;
      }
    }

    return pos;
  };

  return (
    <>
      {HudStyle.is_res_style_active ? (
        <div className="absolute" style={{ ..._positions.bar_res_active }}>
          <DragDropContainer
            noDragging={!isEditorOpen}
            dragElemOpacity={0.75}
            onDragEnd={(_, __, x, y) => {
              handleDragEnd("bar_res_active", x, y);
            }}
          >
            {isEditorOpen && (
              <button className="absolute -left-5 -top-6 z-10 p-2 rounded-full border border-white/15 bg-white/15">
                <FaLocationCrosshairs />
              </button>
            )}
            <div className="flex gap-3 items-end">
              <div
                className="min-w-80 pb-1.5 pt-3 rounded-sm flex items-center justify-center w-full"
                style={{
                  background: "linear-gradient(180deg, rgba(33, 33, 33, 0.6) 0%, rgba(13, 13, 13, 0.4) 100%)",
                }}
              >
                <div className="flex gap-1 items-center w-full h-full px-4">
                  <div className="flex flex-col gap-3 w-full">
                    <div className="flex items-center justify-around gap-3">
                      {(["hunger", "thirst"] as BarType[]).map((slot, index) => (
                        <div
                          key={index}
                          className={classNames("bar", {
                            small: ["grt-premium", "square", "wave-c", "wave-h", "classic"].includes(HudStyle.bar_style),
                          })}
                        >
                          <BarIcon slot={slot} bar={BarsInfo[slot]} barStyle={HudStyle.bar_style} />
                        </div>
                      ))}
                    </div>
                    <div className="relative h-[5px] bg-black/50 rounded-lg overflow-hidden">
                      <div
                        className="absolute h-full"
                        style={{
                          width: `${BarsInfo.health.value}%`,
                          backgroundColor: BarsInfo.health.color,
                        }}
                      ></div>
                    </div>
                  </div>
                  <div className="flex flex-col items-center justify-center h-full">
                    <div className="relative h-full flex items-center justify-center">
                      <div className="w-9 h-11">
                        <svg width="36" height="42" viewBox="0 0 36 42" fill="none" xmlns="http://www.w3.org/2000/svg">
                          <path
                            id="Vector 99"
                            d="M0 0L36 7.90588V32.6118L0 42V0Z"
                            fill="url(#paint0_linear_343_432)"
                            fillOpacity="0.15"
                            style={{
                              transition: "fill 0.3s linear",
                            }}
                          />
                          <defs>
                            <linearGradient id="paint0_linear_343_432" x1="36" y1="20.7529" x2="3.72447e-07" y2="20.7529" gradientUnits="userSpaceOnUse">
                              <stop stopColor={BarsInfo.voice?.isTalking ? VOICE_TALKING_COLOR : "white"} />
                              <stop offset="1" stopColor={BarsInfo.voice?.isTalking ? VOICE_TALKING_COLOR : "white"} stopOpacity="0" />
                            </linearGradient>
                          </defs>
                        </svg>
                      </div>
                      <div className="w-9 h-11">
                        <svg width="36" height="42" viewBox="0 0 36 42" fill="none" xmlns="http://www.w3.org/2000/svg">
                          <path
                            id="Vector 98"
                            d="M36 0L0 7.90588V32.6118L36 42V0Z"
                            fill="url(#paint0_linear_343_431)"
                            fillOpacity="0.15"
                            style={{
                              transition: "fill 0.3s ease linear",
                            }}
                          />
                          <defs>
                            <linearGradient id="paint0_linear_343_431" x1="-3.72446e-07" y1="20.7529" x2="36" y2="20.7529" gradientUnits="userSpaceOnUse">
                              <stop stopColor={BarsInfo.voice?.isTalking ? VOICE_TALKING_COLOR : "white"} />
                              <stop offset="1" stopColor={BarsInfo.voice?.isTalking ? VOICE_TALKING_COLOR : "white"} stopOpacity="0" />
                            </linearGradient>
                          </defs>
                        </svg>
                      </div>
                      <div className="absolute">
                        <Icon size="100%" iconReq={`voice.${!ClientInfo.radio.inChannel ? 1 : 2}`} color={BarsInfo.voice?.isTalking ? VOICE_TALKING_COLOR : BarsInfo.voice?.color} />
                      </div>
                    </div>
                    <div className="flex flex-col gap-0.5 items-center">
                      {Array.from({
                        length: BarsInfo.voice?.talkRange,
                      }).map((_, index) => {
                        let color = `rgba(217,217,217,${0.4 + index * 0.2})`;

                        if (BarsInfo.voice?.isTalking) {
                          const alpha = 0 + (index + 1) * 0.35;
                          color = `rgba(127,207,78,${alpha})`;
                        }

                        const width = 7 + index * 6;

                        const style = {
                          background: color,
                          width: width,
                          height: 2,
                        };

                        return <div key={index} className="rounded-full" style={style}></div>;
                      })}
                    </div>
                  </div>
                  <div className="flex flex-col gap-3 w-full">
                    <div className="flex items-center justify-around gap-3">
                      {(["stress", "stamina"] as BarType[]).map((slot, index) => (
                        <div
                          key={index}
                          className={classNames("bar", {
                            small: ["grt-premium", "square", "wave-c", "wave-h", "classic"].includes(HudStyle.bar_style),
                          })}
                        >
                          <BarIcon slot={slot} bar={BarsInfo[slot]} barStyle={HudStyle.bar_style} />
                        </div>
                      ))}
                    </div>
                    <div className="relative h-[5px] bg-black/50 rounded-lg overflow-hidden">
                      <div
                        className="absolute h-full"
                        style={{
                          width: `${BarsInfo.armor.value}%`,
                          backgroundColor: BarsInfo.armor.color,
                        }}
                      ></div>
                    </div>
                  </div>
                </div>
              </div>
              <div className="flex flex-col gap-3">
                {[
                  {
                    condition: BarsInfo.oxygen.value !== 100,
                    slot: "oxygen" as BarType,
                    bar: BarsInfo.oxygen,
                  },
                  {
                    condition: !!(VehicleInfo.entity && BarsInfo.vehicle_engine.value !== 100),
                    slot: "vehicle_engine" as BarType,
                    bar: BarsInfo.vehicle_engine,
                  },
                  {
                    condition: !!(VehicleInfo.entity && BarsInfo.vehicle_nitro.value !== 0),
                    slot: "vehicle_nitro" as BarType,
                    bar: BarsInfo.vehicle_nitro,
                  },
                ].map(({ condition, slot, bar }) => {
                  const { autoHide, value } = BarsInfo[slot];
                  const isHidden = !!(typeof autoHide == "number" && autoHide < 100 && (autoHide < value || autoHide === 0));
                  return (
                    !isHidden &&
                    condition && (
                      <div key={slot} className="bar small">
                        <BarIcon slot={slot as BarType} bar={bar} barStyle={HudStyle.bar_style} />
                      </div>
                    )
                  );
                })}
              </div>
            </div>
          </DragDropContainer>
        </div>
      ) : (
        <>
          {HudStyle.bar_style != "universal" && HudStyle.bar_style != "zarg-m" && (
            <div className="absolute" style={{ ..._positions.bar_default }}>
              <DragDropContainer
                noDragging={!isEditorOpen}
                dragElemOpacity={0.75}
                onDragEnd={(_, __, x, y) => {
                  handleDragEnd("bar_default", x, y);
                }}
              >
                <div className="flex items-center gap-2">
                  {Bars.map((slot, i) => {
                    const { autoHide, value } = BarsInfo[slot];
                    const isHidden = !!((typeof autoHide == "number" && autoHide < 100 && (autoHide < value || autoHide === 0)) || (slot == "vehicle_nitro" && (value == 0 || !VehicleInfo.entity)) || (slot == "vehicle_engine" && !VehicleInfo.entity));

                    return (
                      !isHidden && (
                        <div
                          key={i}
                          className={classNames(
                            "bar",
                            {
                              small: ["square", "wave-c", "wave-h"].includes(HudStyle.bar_style),
                              large: ["hexagon-w", "hexagon"].includes(HudStyle.bar_style),
                              "hud-bar-size": HudStyle?.bar_size && HudStyle?.bar_size > 0,
                            },
                            HudStyle.bar_style
                          )}
                          style={{ "--bar-size": HudStyle.bar_size?.toString() + "px" } as React.CSSProperties}
                        >
                          <BarIcon slot={slot} bar={BarsInfo[slot]} barStyle={HudStyle.bar_style} />
                          {["wave-c", "wave-h", "classic", "hexagon"].includes(HudStyle.bar_style) && (
                            <h1 className="text-11 2k:text-sm text-center mt-0.5 font-medium text-white/80">
                              {Math.floor(BarsInfo[slot].value || 0)}
                              {"%"}
                            </h1>
                          )}
                        </div>
                      )
                    );
                  })}
                </div>
              </DragDropContainer>
            </div>
          )}
          {HudStyle.bar_style === "universal" && (
            <div className="absolute -mb-3" style={{ ..._positions.bar_universal }}>
              <DragDropContainer
                noDragging={!isEditorOpen}
                dragElemOpacity={0.75}
                onDragEnd={(_, __, x, y) => {
                  handleDragEnd("bar_universal", x, y);
                }}
              >
                <div className="flex flex-col gap-3">
                  <div className="flex items-center gap-3">
                    {Bars.filter((slot) => !["health", "armor"].includes(slot)).map((slot, i) => {
                      const { autoHide, value } = BarsInfo[slot];
                      const isHidden = !!((typeof autoHide == "number" && autoHide < 100 && (autoHide < value || autoHide === 0)) || (slot == "vehicle_nitro" && (value == 0 || !VehicleInfo.entity)) || (slot == "vehicle_engine" && !VehicleInfo.entity));

                      return (
                        !isHidden && (
                          <div key={i} className="bar small">
                            <BarIcon slot={slot} bar={BarsInfo[slot]} barStyle={HudStyle.bar_style} />
                          </div>
                        )
                      );
                    })}
                  </div>
                  <div className="flex items-center gap-3 w-80">
                    {(["health", "armor"] as BarType[]).map((slot, i) => (
                      <div key={i} className="bar !w-full relative rounded overflow-hidden extrasmall" style={{ background: "#0000004d" }}>
                        <div className="absolute z-10 w-full h-full flex items-center justify-center">
                          <Icon iconReq={`${slot}.${BarsInfo[slot]?.style || 1}`} color={getIconColor(HudStyle.bar_style, BarsInfo[slot]?.color)} />
                        </div>
                        <div
                          className="absolute h-full"
                          style={{
                            width: `${BarsInfo[slot].value}%`,
                            backgroundColor: BarsInfo[slot].color,
                          }}
                        ></div>
                      </div>
                    ))}
                  </div>
                </div>
              </DragDropContainer>
            </div>
          )}
          {HudStyle.bar_style === "zarg-m" && (
            <>
              {(["health", "armor"] as BarType[]).map((slot, i) => {
                return (
                  <div key={i} className="absolute" style={{ ...calcZargmPosition(slot) }}>
                    <DragDropContainer
                      noDragging={!isEditorOpen}
                      dragElemOpacity={0.75}
                      onDragEnd={(_, __, x, y) => {
                        handleDragEnd("bar_zarg_m", x, y, slot);
                      }}
                    >
                      <div
                        className={classNames("border-2 border-transparent rounded", {
                          "border-transparent": !isEditorOpen,
                          "border-white bg-white/10": isEditorOpen && slot == "armor",
                          "border-[#CF4E5B] bg-[#CF4E5B]/10": isEditorOpen && slot == "health",
                        })}
                        style={{ width: 260 }}
                      >
                        <ProgressBar rotation={slot == "health" ? 0.05 : 0.45} counterClockwise={slot == "health"} occupancy={BarsInfo[slot]?.value} progressColor={slot == "health" ? "#CF4E5B" : "#FFFFFF"} shape={HudStyle.bar_style}>
                          <Icon iconReq={`${slot}.${BarsInfo[slot]?.style || 1}`} color={slot == "health" ? "#CF4E5B" : "#FFFFFF"} />
                        </ProgressBar>
                      </div>
                    </DragDropContainer>
                  </div>
                );
              })}
              {(["stamina", "stress", "oxygen"] as BarType[]).map((slot, i) => {
                const { autoHide, value } = BarsInfo[slot];
                const isHidden = !!(typeof autoHide == "number" && autoHide < 100 && (autoHide < value || autoHide === 0));

                return (
                  !isHidden && (
                    <div key={i} className="absolute" style={{ ...calcZargmPosition(slot) }}>
                      <DragDropContainer
                        noDragging={!isEditorOpen}
                        dragElemOpacity={0.75}
                        onDragEnd={(_, __, x, y) => {
                          handleDragEnd("bar_zarg_m", x, y, slot);
                        }}
                      >
                        <div className="bar">
                          <ProgressBar occupancy={BarsInfo[slot]?.value} progressColor={slot === "voice" && BarsInfo[slot]?.isTalking ? VOICE_TALKING_COLOR : BarsInfo[slot]?.color} shape={"zarg"}>
                            <Icon iconReq={`${slot}.${BarsInfo[slot]?.style || 1}`} color={slot === "voice" && BarsInfo[slot]?.isTalking ? VOICE_TALKING_COLOR : BarsInfo[slot]?.color} />
                          </ProgressBar>
                        </div>
                      </DragDropContainer>
                    </div>
                  )
                );
              })}
              {(["voice", "hunger", "thirst"] as BarType[]).map((slot, i) => {
                const isHidden = BarsInfo[slot].autoHide && ((BarsInfo[slot].autoHide != 100 && BarsInfo[slot]?.autoHide < BarsInfo[slot]?.value) || BarsInfo[slot].autoHide == 0);
                return (
                  !isHidden && (
                    <div key={i} className="absolute" style={{ ...calcZargmPosition(slot) }}>
                      <DragDropContainer
                        noDragging={!isEditorOpen}
                        dragElemOpacity={0.75}
                        onDragEnd={(_, __, x, y) => {
                          handleDragEnd("bar_zarg_m", x, y, slot);
                        }}
                      >
                        <div className="bar">
                          <ProgressBar occupancy={BarsInfo[slot]?.value} progressColor={slot === "voice" && BarsInfo[slot]?.isTalking ? VOICE_TALKING_COLOR : BarsInfo[slot]?.color} shape={"zarg"}>
                            <Icon iconReq={`${slot}.${BarsInfo[slot]?.style || 1}`} color={slot === "voice" && BarsInfo[slot]?.isTalking ? VOICE_TALKING_COLOR : BarsInfo[slot]?.color} />
                          </ProgressBar>
                        </div>
                      </DragDropContainer>
                    </div>
                  )
                );
              })}
            </>
          )}
        </>
      )}
    </>
  );
};
