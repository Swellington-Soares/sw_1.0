import React from "react";
import "./index.scss";
import { useEffect, useState, useCallback } from "react";
import { CarControl, Bucket, Music, Options, TypeOfBars, TypeOfVehicleHud } from "@/pages/Settings/Partials/Layers";
import { useVisibility } from "@/hooks/useVisibility";
import { isEnvBrowser } from "@/utils/misc";
import { fetchNui } from "@/utils/fetchNui";
import classNames from "classnames";
import { FaCarCrash } from "react-icons/fa";
import useData from "@/hooks/useData";

export type LayerPages = "bucket" | "boxof" | "boxof-vehicle" | "car-control" | "music" | "options";

export const Settings: React.FC = () => {
  const { visible } = useVisibility();
  const { setEditorOpen, MusicInfo } = useData();
  const [activePage, setActivePage] = useState<LayerPages>("bucket");

  useEffect(() => {
    if (!visible) return;
    const keyHandler = (e: KeyboardEvent) => {
      if (!isEnvBrowser() && ["Escape"].includes(e.code)) {
        setEditorOpen(false);
        fetchNui("nui:hideFrame", true, true);
      }
    };
    window.addEventListener("keydown", keyHandler);
    return () => window.removeEventListener("keydown", keyHandler);
  }, [visible, setEditorOpen]);

  const onChangePage = useCallback((page: LayerPages) => {
    setActivePage(page);
  }, []);

  return (
    <>
      <div className="flex flex-col select-none min-w-80 h-full justify-end" style={{ height: 320 }}>
        <div className="h-8 2k:h-10 border-2 border-b-0 border-solid border-212121 rounded-t-sm bg-121212/95">
          <div className="w-full h-full flex justify-between items-center page-bar-elements">
            <button
              onClick={() => onChangePage("bucket")}
              className={classNames("element flex items-center justify-center", {
                active: activePage == "bucket",
              })}
            >
              <div className="w-full h-full p-0.5 flex items-center justify-center" style={{ opacity: activePage == "bucket" ? 1 : 0.25 }}>
                <img src="images/icons/bucket.svg" alt="bucket" />
              </div>
            </button>
            <button
              onClick={() => onChangePage("boxof")}
              className={classNames("element", {
                active: activePage == "boxof",
              })}
            >
              <div className="w-full h-full p-0.5 flex items-center justify-center" style={{ opacity: activePage == "boxof" ? 1 : 0.25 }}>
                <img src="images/icons/boxof.svg" alt="box-of" />
              </div>
            </button>
            <button
              onClick={() => onChangePage("boxof-vehicle")}
              className={classNames("element", {
                active: activePage == "boxof-vehicle",
              })}
            >
              <div className="w-full h-full p-0.5 flex items-center justify-center" style={{ opacity: activePage == "boxof-vehicle" ? 1 : 0.25 }}>
                <FaCarCrash className={classNames("scale-150 w-full h-full text-white")} />
              </div>
            </button>
            <button
              onClick={() => onChangePage("car-control")}
              className={classNames("element", {
                active: activePage == "car-control",
              })}
            >
              <div className="w-full h-full p-0.5 flex items-center justify-center" style={{ opacity: activePage == "car-control" ? 1 : 0.25 }}>
                <img src="images/icons/car-control.svg" alt="car-control" />
              </div>
            </button>
            <button
              onClick={() => MusicInfo.active && onChangePage("music")}
              className={classNames("element", {
                active: activePage == "music",
                "opacity-50 !cursor-default": !MusicInfo.active,
              })}
            >
              <div className="w-full h-full p-0.5 flex items-center justify-center" style={{ opacity: activePage == "music" ? 1 : 0.25 }}>
                <img src="images/icons/music-layer.svg" alt="music" />
              </div>
            </button>
            <button
              onClick={() => onChangePage("options")}
              className={classNames("element", {
                active: activePage == "options",
              })}
            >
              <div className="w-full h-full p-0.5 flex items-center justify-center" style={{ opacity: activePage == "options" ? 1 : 0.25 }}>
                <img src="images/icons/settings.svg" alt="options" />
              </div>
            </button>
          </div>
        </div>
        <div className=" border-x-2 border-b-2 border-212121 rounded-b-sm bg-0D0D0D/85 settings-layers">
          {activePage === "bucket" && (
            <div id="bucket">
              <Bucket />
            </div>
          )}
          {activePage === "boxof" && (
            <div id="boxof">
              <TypeOfBars />
            </div>
          )}
          {activePage === "boxof-vehicle" && (
            <div id="boxof-vehicle">
              <TypeOfVehicleHud />
            </div>
          )}
          {activePage === "car-control" && (
            <div id="car-control">
              <CarControl />
            </div>
          )}
          {activePage === "music" && (
            <div id="music">
              <Music />
            </div>
          )}
          {activePage === "options" && (
            <div id="options">
              <Options />
            </div>
          )}
        </div>
      </div>
    </>
  );
};
