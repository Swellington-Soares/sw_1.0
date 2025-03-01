import useData from "@/hooks/useData";
import { formatNumberWithComma, getFormattedDate, padNumber } from "@/utils/misc";
import { useTranslation } from "react-i18next";
import { DragDropContainer } from "react-drag-drop-container-typescript";
import { FaLocationCrosshairs } from "react-icons/fa6";
import classNames from "classnames";

export const ClientInfo = () => {
  const { t } = useTranslation();
  const { ClientInfo, onChangeHudPositions, isEditorOpen } = useData();

  const { real_time, server_info, bank, active, cash, extra_currency, job, player_source, radio, time, weapon, positions } = ClientInfo;

  const posStyle = {} as any;
  if (positions.x) {
    posStyle.left = positions.x;
  } else {
    posStyle.right = 8;
  }
  posStyle.top = positions.y || 56;

  const handleDragEnd = (key: string, x: number, y: number) => {
    onChangeHudPositions(key, x, y);
  };

  const MoneyIcon = () =>
    t("money_type") == "$" ? (
      <svg width="14" height="14" viewBox="0 0 14 14" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path id="Vector" fillRule="evenodd" clipRule="evenodd" d="M7 0C10.866 0 14 3.13403 14 7C14 10.866 10.866 14 7 14C3.13403 14 0 10.866 0 7C0 3.13403 3.13403 0 7 0ZM6.44584 10.8245V11.2759C6.44584 11.582 6.69406 11.8301 7 11.8301C7.3061 11.8301 7.55416 11.5818 7.55416 11.2759V10.8347C8.04784 10.7612 8.553 10.5828 8.95113 10.2809C10.1374 9.3808 9.89148 7.68646 8.66616 6.94671C8.19546 6.66251 7.63318 6.51827 7.09509 6.42991C6.50295 6.33268 5.64545 6.11524 5.60992 5.38452C5.59936 5.16616 5.6554 4.9596 5.78234 4.7809C5.98125 4.50098 6.32288 4.33423 6.65225 4.26793C6.91425 4.2151 7.20259 4.22153 7.4606 4.28707C7.93039 4.4062 8.29039 4.71398 8.47828 5.16157C8.59665 5.44363 8.92143 5.57654 9.20348 5.45818C9.48554 5.33981 9.61846 5.01503 9.50009 4.73297C9.17408 3.95632 8.54443 3.41976 7.72965 3.21335C7.67161 3.19865 7.61296 3.18579 7.55401 3.17491V2.72426C7.55401 2.41832 7.30579 2.1701 6.99985 2.1701C6.69375 2.1701 6.44568 2.41832 6.44568 2.72426V3.18303C5.84252 3.3017 5.26723 3.61561 4.89727 4.1148C4.61078 4.50144 4.482 4.95745 4.50527 5.43689C4.57081 6.78562 5.74605 7.32922 6.91716 7.52155C7.30977 7.58601 7.75216 7.68846 8.09439 7.89502C8.64411 8.227 8.84058 8.979 8.28381 9.40147C8.01798 9.60314 7.65415 9.70849 7.32585 9.74831C6.84274 9.80695 6.33543 9.7359 5.92261 9.46104C5.64422 9.27561 5.45037 9.01238 5.36936 8.68546C5.29586 8.38916 4.99681 8.20771 4.7002 8.28059C4.4036 8.35348 4.22168 8.6533 4.29534 8.94991C4.44463 9.55093 4.79851 10.0415 5.31148 10.3832C5.65203 10.6099 6.04358 10.755 6.44584 10.8245Z" fill="white" />
      </svg>
    ) : (
      <div className="rounded-full w-3.5 h-3.5 bg-white flex items-center justify-center text-212121">
        <h1 className="text-9 font-bold">{t("money_type")}</h1>
      </div>
    );

  return (
    active && (
      <>
        <div id="client_info" className="absolute select-none 4k:scale-150 4k:-translate-x-16 4k:translate-y-20" style={posStyle}>
          <DragDropContainer
            noDragging={!isEditorOpen}
            dragElemOpacity={0.75}
            onDragEnd={(_, __, x, y) => {
              handleDragEnd("client_info", x, y);
            }}
          >
            {isEditorOpen && (
              <button className="absolute -left-5 -top-6 z-10 p-2 rounded-full border border-white/15 bg-white/15">
                <FaLocationCrosshairs />
              </button>
            )}
            <div className="flex flex-col justify-end select-none">
              <div className="flex gap-2 justify-end">
                <div className="flex flex-col items-end justify-start">
                  <div className="flex gap-2 items-center">
                    {radio.active && radio.show && radio.inChannel && (
                      <div className="flex gap-1">
                        <img src="images/icons/radio.svg" alt="radio" />
                        <h1 className="font-bold text-sm text-white/75">{radio.channel}</h1>
                      </div>
                    )}
                    {player_source.active && player_source.show && (
                      <div className="flex gap-1">
                        <h1 className="font-bold text-sm text-white">ID</h1>
                        <h1 className="font-bold text-sm text-white/75">#{player_source.source}</h1>
                      </div>
                    )}
                    {server_info.active && server_info.show && server_info.maxPlayers > 0 && (
                      <div className="flex gap-1 items-center">
                        <h1 className="font-bold text-sm text-white">{t("players")}</h1>
                        <h1 className="font-bold text-sm text-white/75">
                          {server_info.playerCount}
                          {"/"}
                          {server_info.maxPlayers}
                        </h1>
                      </div>
                    )}
                  </div>
                  {time.active && time.show && (
                    <div className="flex gap-3 items-center justify-end w-full">
                      <div className="flex items-center gap-0.5">
                        {time.gameHours >= 6 && time.gameHours < 18 ? <img src="images/icons/time_morning.svg" alt="morning" /> : <img className="mt-1" src="images/icons/time_night.svg" alt="night" />}
                        <div>
                          <h1 className="uppercase text-sm font-bold text-white/75 -mb-1 text-center">{t("time")}</h1>
                          <h1 className="text-sm font-bold text-white text-center">
                            {padNumber(time.gameHours)}
                            {":"}
                            {padNumber(time.gameMinutes)}
                          </h1>
                        </div>
                      </div>
                    </div>
                  )}
                </div>
                {server_info.active && server_info.show && (
                  <div className="flex items-start overflow-hidden">
                    <img className="rounded max-w-16 max-h-16" src={`images/server_images/${server_info.image}`} alt="server_image" />
                  </div>
                )}
              </div>
              {server_info.active && server_info.show && <h1 className={classNames("text-xs text-white text-right font-medium", { "-mt-3": time.active && time.show })}>{server_info.name}</h1>}
              <div className="mt-2 flex flex-col gap-3 items-end">
                {cash.active && cash.show && (
                  <div
                    className="flex items-center gap-3 py-1 pl-4 rounded"
                    style={{
                      background: "radial-gradient(circle, rgba(33, 33, 33, 0.1) 0%, rgba(33, 33, 33, 0.1) 100%)",
                    }}
                  >
                    <div className="flex flex-col items-end">
                      <h1 className="text-white/75 text-sm font-bold">{t("cash")}</h1>
                      <div className="flex items-center gap-1">
                        <MoneyIcon />
                        <h1 className="text-white font-bold text-sm">{formatNumberWithComma(cash.amount)}</h1>
                      </div>
                    </div>
                    <div className="relative w-9 h-9 min-h-9 min-w-9 flex items-center justify-center">
                      <div className="w-full h-full bg-0D0D0D/85 rounded border-2 border-solid border-white/15 opacity-50"></div>
                      <div className="absolute w-full h-full p-2.5 flex items-center justify-center">
                        <MoneyIcon />
                      </div>
                    </div>
                  </div>
                )}
                {bank.active && bank.show && (
                  <div
                    className="flex items-center gap-3 py-1 pl-4 rounded"
                    style={{
                      background: "radial-gradient(circle, rgba(33, 33, 33, 0.1) 0%, rgba(33, 33, 33, 0.1) 100%)",
                    }}
                  >
                    <div className="flex flex-col items-end">
                      <h1 className="text-white/75 text-sm font-bold">{t("bank")}</h1>
                      <div className="flex items-center gap-1">
                        <MoneyIcon />
                        <h1 className="text-white font-bold text-sm">{formatNumberWithComma(bank.amount)}</h1>
                      </div>
                    </div>
                    <div className="relative w-9 h-9 min-h-9 min-w-9 flex items-center justify-center">
                      <div className="w-full h-full bg-0D0D0D/85 rounded border-2 border-solid border-white/15 opacity-50"></div>
                      <img className="absolute w-full h-full p-2.5" src="images/icons/bank.svg" alt="bank" />
                    </div>
                  </div>
                )}
                {extra_currency.active && extra_currency.show && (
                  <div
                    className="flex items-center gap-3 py-1 pl-4 rounded"
                    style={{
                      background: "radial-gradient(circle, rgba(33, 33, 33, 0.1) 0%, rgba(33, 33, 33, 0.1) 100%)",
                    }}
                  >
                    <div className="flex flex-col items-end">
                      <h1 className="text-white/75 text-sm font-bold">{t("other_currency")}</h1>
                      <div className="flex items-center gap-1">
                        <MoneyIcon />
                        <h1 className="text-white font-bold text-sm">{formatNumberWithComma(extra_currency.amount)}</h1>
                      </div>
                    </div>
                    <div className="relative w-9 h-9 min-h-9 min-w-9 flex items-center justify-center">
                      <div className="w-full h-full bg-0D0D0D/85 rounded border-2 border-solid border-white/15 opacity-50"></div>
                      <div className="absolute w-full h-full p-2.5 flex items-center justify-center">
                        <MoneyIcon />
                      </div>
                    </div>
                  </div>
                )}
                {job.active && job.show && (
                  <div
                    className="flex items-center gap-3 py-1 pl-4 rounded"
                    style={{
                      background: "radial-gradient(circle, rgba(33, 33, 33, 0.1) 0%, rgba(33, 33, 33, 0.1) 100%)",
                    }}
                  >
                    <div className="flex flex-col items-end">
                      <h1 className="text-white/75 text-sm font-bold">{t("current_job")}</h1>
                      <div className="text-white font-bold text-sm flex items-center">
                        <h1>{job.label}</h1>
                        <span className="mx-0.5">{"/"}</span>
                        <h1 className="text-white/75 lowercase first-letter:uppercase">{job.gradeLabel}</h1>
                      </div>
                    </div>
                    <div className="relative w-9 h-9 min-h-9 min-w-9 flex items-center justify-center">
                      <div className="w-full h-full bg-0D0D0D/85 rounded border-2 border-solid border-white/15 opacity-50"></div>
                      <img className="absolute w-full h-full p-2.5" src="images/icons/job_bag.svg" alt="job_bag" />
                    </div>
                  </div>
                )}
                {weapon.active && weapon.show && (
                  <div
                    className="flex items-center gap-3 py-1 pl-4 rounded"
                    style={{
                      background: "radial-gradient(circle, rgba(33, 33, 33, 0.1) 0%, rgba(33, 33, 33, 0.1) 100%)",
                    }}
                  >
                    <div className="flex flex-col items-end">
                      <h1 className="text-white/75 text-sm font-bold">{t("weapon")}</h1>
                      <div className="flex items-center gap-0.5">
                        <h1 className="text-white font-bold text-sm">{weapon.name}</h1>
                        {weapon.ammo.inClip > 0 && weapon.ammo.inWeapon > 0 && (
                          <>
                            <h1 className="mx-0.5 h-1 w-1 bg-white/75 rounded-full"></h1>
                            <h1 className="text-white font-bold text-sm">
                              {weapon.ammo.inClip}
                              <span hidden={weapon.ammo.inWeapon - weapon.ammo.inClip == 0}>{"/"}</span>
                              <span hidden={weapon.ammo.inWeapon - weapon.ammo.inClip == 0}>{weapon.ammo.inWeapon - weapon.ammo.inClip}</span>
                            </h1>
                          </>
                        )}
                      </div>
                    </div>
                    <div className="relative w-9 h-9 min-h-9 min-w-9 flex items-center justify-center">
                      <div className="w-full h-full bg-0D0D0D/85 rounded border-2 border-solid border-white/15 opacity-50"></div>
                      <img className="absolute w-full h-full p-2.5" src="images/icons/weapon.svg" alt="weapon" />
                    </div>
                  </div>
                )}
              </div>
            </div>
          </DragDropContainer>
        </div>
        {real_time.active && time.show && (
          <div className="fixed top-1 right-1 4k:-translate-x-8">
            <h1 className="text-xs font-bold text-white/75 text-right">{getFormattedDate()}</h1>
          </div>
        )}
      </>
    )
  );
};
