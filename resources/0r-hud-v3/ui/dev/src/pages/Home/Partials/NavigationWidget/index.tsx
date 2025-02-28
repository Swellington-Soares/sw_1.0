import useData from "@/hooks/useData";
import { Settings } from "@/pages/Settings";
import { padNumber } from "@/utils/misc";
import { useState } from "react";
import { DragDropContainer } from "react-drag-drop-container-typescript";
import { useTranslation } from "react-i18next";
import { FaLocationCrosshairs } from "react-icons/fa6";

export const NavigationWidget = () => {
  const { t } = useTranslation();
  const { Cinematic, NavigationWidget, ClientInfo, MusicInfo, Compass, MiniMap, HudStyle, VehicleInfo, onChangeHudPositions, isSettingsOpen, isEditorOpen } = useData();

  let widgetBottomStyle = 300;
  if (MiniMap.onlyInVehicle && !VehicleInfo.entity) {
    if (HudStyle.is_res_style_active) {
      widgetBottomStyle = 100;
    } else {
      if (HudStyle.bar_style == "universal") {
        widgetBottomStyle = 105;
      } else if (HudStyle.bar_style != "zarg-m") {
        widgetBottomStyle = 80;
      }
    }
  } else {
    if (!HudStyle.is_res_style_active) {
      if (HudStyle.bar_style == "zarg-m") {
        widgetBottomStyle = 310;
      }
    }
  }

  const { positions } = NavigationWidget;

  const posStyle = {} as any;
  if (positions.x) {
    posStyle.left = positions.x;
  } else {
    posStyle.left = 16;
  }
  if (positions.y) {
    posStyle.top = positions.y;
    if (!isSettingsOpen) {
      posStyle.top += 324;
    }
  } else {
    posStyle.bottom = widgetBottomStyle;
  }

  const handleDragEnd = (key: string, x: number, y: number) => {
    onChangeHudPositions(key, x, y);
  };

  const [isDragActive, setDragActive] = useState<boolean>(false);

  const handleMouseDown = () => {
    setTimeout(() => {
      setDragActive(true);
    }, 200);
  };

  const handleMouseUp = () => {
    setTimeout(() => {
      setDragActive(false);
    }, 200);
  };

  return (
    <>
      <div id="navigation-widget" className="absolute select-none w-80" style={posStyle}>
        <DragDropContainer
          noDragging={!isDragActive}
          dragElemOpacity={0.75}
          onDragEnd={(_, __, x, y) => {
            setDragActive(false);
            handleDragEnd("navigation_widget", x, y);
          }}
        >
          <div className="2k:!mb-14 flex flex-col items-center gap-1">
            {isSettingsOpen && (
              <>
                {isEditorOpen && (
                  <button className="absolute -left-5 -top-6 z-10 p-2 rounded-full border border-white/15 bg-white/15" onMouseDown={handleMouseDown} onMouseUp={handleMouseUp}>
                    <FaLocationCrosshairs />
                  </button>
                )}
                <Settings />
              </>
            )}
            {NavigationWidget.active && NavigationWidget.show && !Cinematic.show && (
              <div
                className="w-full h-[51px] relative border-2 border-solid border-transparent rounded-sm overflow-hidden"
                style={{
                  background: "radial-gradient(circle, rgba(33, 33, 33, 0.6) 0%, rgba(13, 13, 13, 0.4) 100%)",
                }}
              >
                <div className="relative w-full flex justify-between items-center z-10 h-full px-2">
                  <div className="flex items-center gap-2 flex-grow w-full">
                    <img src="images/icons/navigation.svg" alt="navigation" />
                    <div className="overflow-hidden pr-1 min-w-0">
                      <h1 className="text-xs 2k:text-sm font-bold whitespace-nowrap text-ellipsis overflow-hidden">{(NavigationWidget?.navigation.isDestinationActive && NavigationWidget?.navigation?.currentStreet) || Compass.street1 || t("location")}</h1>
                      <h1 className="text-sm 2k:text-base font-bold whitespace-nowrap text-ellipsis overflow-hidden">{(NavigationWidget?.navigation.isDestinationActive && NavigationWidget?.navigation?.destinationStreet) || Compass.street2 || t("location")}</h1>
                    </div>
                  </div>
                  {MusicInfo.isPlaying && (
                    <div className="flex items-center justify-end gap-0.5 overflow-hidden w-full">
                      <div className="scale-90">
                        <img src="images/core/music.gif" alt="music_grd" />
                      </div>
                      <div className="p-1.5 rounded-full bg-black/25 w-2/3">
                        <img className="w-full h-full min-w-full min-h-full" src="images/icons/music.svg" alt="music" />
                      </div>
                    </div>
                  )}
                  {!MusicInfo.isPlaying && (
                    <div className="flex gap-2 items-center justify-end w-full">
                      {ClientInfo.time.gameHours >= 6 && ClientInfo.time.gameHours < 18 ? <img src="images/icons/time_morning.svg" alt="morning" /> : <img className="mt-1" src="images/icons/time_night.svg" alt="night" />}
                      <div>
                        <h1 className="uppercase text-xs text-white 2k:text-sm font-sentic-text-bold font-bold">{t("time")}</h1>
                        <h1 className="text-xs text-white 2k:text-sm font-medium">
                          {padNumber(ClientInfo.time.gameHours)}
                          {":"}
                          {padNumber(ClientInfo.time.gameMinutes)}
                        </h1>
                      </div>
                    </div>
                  )}
                </div>
              </div>
            )}
          </div>
        </DragDropContainer>
      </div>
    </>
  );
};
