import useData from "@/hooks/useData";
import { useState } from "react";
import { useTranslation } from "react-i18next";
import { FaPlayCircle, FaPauseCircle } from "react-icons/fa";
import { FaCirclePlus } from "react-icons/fa6";
import { fetchNui } from "@/utils/fetchNui";

const Music = () => {
  const { t } = useTranslation();
  const [isSleep, setSleep] = useState<boolean>(false);
  const { MusicInfo, setMusicInfo } = useData();

  const [musicURL, setMusicURL] = useState<string>("");

  const [isSearchActive, setSearchActive] = useState<boolean>(false);

  const isValidUrl = (url: string): boolean => {
    try {
      new URL(url);
      return true;
    } catch {
      return false;
    }
  };

  const fetchRequest = async (event: string, data?: any, mockData?: any) => {
    if (isSleep) return false;
    setSleep(true);
    try {
      const result = await fetchNui(event, data, mockData);
      return result;
    } catch (error) {
      console.error("Error: ", error);
      return false;
    } finally {
      setTimeout(() => {
        setSleep(false);
      }, 500);
    }
  };

  const handleToggleCurrentMusic = async () => {
    const result = await fetchRequest("nui:toggleCurrentMusic", true, true);
    if (result) {
      setMusicInfo((p) => ({
        ...p,
        isPlaying: !p.isPlaying,
      }));
    }
  };

  const handlePlayNewMusic = async () => {
    if (musicURL && isValidUrl(musicURL)) {
      const result = await fetchRequest("nui:playNewMusic", musicURL, {
        name: "Cakal - Yildizlar",
        label: "Cakal",
      });
      if (result) {
        setMusicInfo((p) => ({
          ...p,
          isPlaying: true,
          songName: result.name,
          songLabel: result.label,
          list: [...(p.list || []), { name: result.name, url: musicURL }],
        }));
      }
    }
    setSearchActive(false);
    setMusicURL("");
  };

  const handlePlayMusicAgain = async (url: string) => {
    const result = await fetchRequest("nui:playNewMusic", url, {
      name: "Cakal - Yildizlar Yeniden",
      label: "Cakal",
    });
    if (result) {
      setMusicInfo((p) => ({
        ...p,
        isPlaying: true,
        songName: result.name,
        songLabel: result.label,
      }));
    }
  };

  return (
    <>
      <div className="relative p-2.5 flex flex-col" style={{ minHeight: 280, maxHeight: 280 }}>
        <div
          className="w-full h-[98px] border border-solid border-white/15 rounded p-2"
          style={{
            background: "linear-gradient(84deg, rgba(84, 255, 91, 0.21) 0%, rgba(84, 245, 255, 0.21) 100%)",
          }}
        >
          <div className="w-full flex">
            <div
              className="min-w-20 max-w-20 min-h-20 max-h-20 bg-cover rounded mr-3"
              style={{
                background: "url(images/core/spoimp.jpeg) lightgray 0px -2.612px / 100% 133.333% no-repeat",
              }}
            ></div>
            <div className="w-full flex flex-col overflow-hidden">
              <div className="flex items-start justify-between">
                <div className="overflow-hidden">
                  <h1 className="text-white/35 text-sm font-bold">{t("music")}</h1>
                  {MusicInfo.songName && (
                    <>
                      <h1 className="text-white text-xs font-bold whitespace-nowrap">{MusicInfo.songName}</h1>
                    </>
                  )}
                </div>
                <img src="images/icons/music.svg" alt="music" />
              </div>
              <div className="mt-3 flex gap-2">
                {!isSearchActive ? (
                  <>
                    <button className="w-6 h-6" onClick={handleToggleCurrentMusic}>
                      {MusicInfo.isPlaying ? <FaPauseCircle className="w-full h-full" /> : <FaPlayCircle className="w-full h-full" />}
                    </button>
                    <button onClick={() => setSearchActive(true)} className="w-6 h-6 opacity-50 hover:opacity-100 transition-opacity">
                      <FaCirclePlus className="w-full h-full" />
                    </button>
                  </>
                ) : (
                  <div className="relative flex items-center gap-1 w-full h-full">
                    <input autoFocus={isSearchActive} type="text" value={musicURL} className="w-full pr-7 block h-7 rounded border-2 border-solid border-white/15 bg-white/20 outline-none ring-0 px-1 text-xs" onChange={(e) => setMusicURL(e.currentTarget.value)} />
                    <button onClick={handlePlayNewMusic} className="absolute right-1 z-50">
                      <img src="images/icons/plus.svg" alt="plus" />
                    </button>
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
        <hr className="mt-1.5 border-white/10 mb-2" />
        <div className="w-full flex flex-col gap-1 overflow-auto scrollbar-hide">
          {(MusicInfo.list || MusicInfo.isPlaying) && (
            <>
              {MusicInfo.isPlaying && (
                <div className="w-full flex rounded border border-white/15 bg-white/25 p-1.5 items-center">
                  <div className="mr-2">
                    <img src="images/icons/music.svg" alt="music" />
                  </div>
                  <div className="overflow-hidden w-full">
                    <h1 className="text-xs font-bold whitespace-nowrap">{MusicInfo.songName}</h1>
                  </div>
                  <div className="ml-auto">
                    <img src="images/icons/music.svg" alt="music" />
                  </div>
                </div>
              )}
              {MusicInfo?.list?.slice(0, 10).map((v, i) => (
                <div key={i} className="w-full flex flex-1 rounded border border-white/15 bg-white/25 p-1.5 opacity-25">
                  <div className="mr-2">
                    <img src="images/icons/music.svg" alt="music" />
                  </div>
                  <div className="overflow-hidden w-full">
                    <h1 className="text-xs font-bold whitespace-nowrap">{v.name}</h1>
                  </div>
                  <button onClick={() => handlePlayMusicAgain(v.url)} className="ml-auto">
                    <FaPlayCircle />
                  </button>
                </div>
              ))}
            </>
          )}
        </div>
      </div>
    </>
  );
};
export default Music;
