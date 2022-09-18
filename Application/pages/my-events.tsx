import type { NextPage } from "next";
import { useAddress } from "@thirdweb-dev/react";

const MyEvents: NextPage = () => {
  const address = useAddress();
  return (
    <div className="px-9">
      <div className="h-screen flex justify-center content-center py-20 flex-wrap">
        Coming Soon !
      </div>
    </div>
  );
};

export default MyEvents;
