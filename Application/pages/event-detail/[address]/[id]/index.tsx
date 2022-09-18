import type { NextPage } from "next";
import { useAddress, useContract, useContractRead } from "@thirdweb-dev/react";
import { useRouter } from "next/router";
import React from "react";

const EventDetail: NextPage = () => {
  const walletAddress = useAddress();
  const router = useRouter();
  const { address, id } = router.query;

  return (
    <div className="px-9">
      <div className="h-screen flex justify-center content-center py-20 flex-wrap">
        <h1>Coming Soon!</h1>
        <h2>Event Contract Address: {address}</h2>
      </div>
    </div>
  );
};

export default EventDetail;
