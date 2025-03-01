import React, { createContext, useMemo, useState } from "react";
import { useNuiEvent } from "@/hooks/useNuiEvent";
import classNames from "classnames";
import { debugData } from "@/utils/debugData";
import { isEnvBrowser } from "@/utils/misc";

debugData([{ action: "ui:setVisible", data: true }]);

export interface VisibilityProviderValue {
  setVisible: (visible: boolean) => void;
  visible: boolean;
}

export const VisibilityCtx = createContext<VisibilityProviderValue>({} as VisibilityProviderValue);

export const VisibilityProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [visible, setVisible] = useState(false);

  useNuiEvent<boolean>("ui:setVisible", setVisible);

  const value = useMemo(() => {
    return {
      visible,
      setVisible,
    };
  }, [visible]);

  return (
    <VisibilityCtx.Provider value={value}>
      <main
        style={{ visibility: visible ? "visible" : "hidden" }}
        className={classNames("w-full h-screen", {
          "bg-black/75": isEnvBrowser(),
        })}
      >
        {children}
      </main>
      {isEnvBrowser() && <div className="fixed inset-0 -z-10 bg-cover bg-center" style={{ backgroundImage: "url(images/core/miko.png)" }}></div>}
    </VisibilityCtx.Provider>
  );
};
