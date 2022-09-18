import type { NextPage } from "next";
import Image from "next/image";
import { useAddress } from "@thirdweb-dev/react";
import { ConnectWallet } from "@thirdweb-dev/react";
import Link from "next/link";

const Home: NextPage = () => {
  const address = useAddress();
  return (
    <div className="px-9">
      <div className="h-screen flex justify-center content-center py-20">
        <div className="w-1/2 py-20">
          <h1 className=" font-bold">Create your WEB3 Event</h1>
          <h2>
            With our EventDash tool you can create your WEB3 Event in a few
            clicks
          </h2>
          {address ? (
            <div className="px-8 my-8">
              <Link href="/create-event">
                <a className="bg-white text-black py-3 px-4 rounded-md text-xl">
                  Create Event
                </a>
              </Link>
            </div>
          ) : (
            <ConnectWallet accentColor="#fff" colorMode="light" />
          )}
        </div>
        <div className="w-1/2 overflow-hidden">
          <Image
            src={require("../assets/img/event-image.jpg").default}
            height={350}
            width={600}
          />
        </div>
      </div>
    </div>
  );
};

export default Home;
