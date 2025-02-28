import "./index.scss";
import { ClientInfo as ClientInfoC } from "./Partials/ClientInfo";
import { Compass as CompassC } from "./Partials/Compass";
import { NavigationWidget as NavigationWidgetC } from "./Partials/NavigationWidget";
import { BarsComponent } from "./Partials/Bars";
import useData from "@/hooks/useData";
import { MoiveBars } from "./Partials/MoiveBars";
import { VehicleHud } from "./Partials/VehicleHud";

export const Home: React.FC = () => {
  const { Cinematic } = useData();

  return (
    <>
      {!Cinematic.show ? (
        <>
          <ClientInfoC />
          <CompassC />
          <BarsComponent />
          <VehicleHud />
        </>
      ) : (
        <MoiveBars />
      )}
      <NavigationWidgetC />
    </>
  );
};
