import React from "react";
import { NextComponentType } from "next";
import Link from "next/link";
import { ConnectWallet } from "@thirdweb-dev/react";
import { useAddress } from "@thirdweb-dev/react";

const Header: NextComponentType = () => {
  const address = useAddress();
  return (
    <nav className="p-5 border-b2 flex flex-row justify-between items-center">
      <Link href="/">
        <a className="py-4 px-4 font-bold text-3xl">EventDash</a>
      </Link>
      <div className="flex flex-row items-center">
        <Link href="/">
          <a className="mr-4 p-6">Home</a>
        </Link>

        <Link href="/events">
          <a className="mr-4 p-6">Events</a>
        </Link>
        {address ? (
          <Link href="/create-event">
            <a className="mr-4 p-6">Create Event</a>
          </Link>
        ) : null}
        {address ? (
          <Link href="/my-events">
            <a className="mr-4 p-6">My Events</a>
          </Link>
        ) : null}
        <ConnectWallet accentColor="#fff" colorMode="light" />
      </div>
    </nav>
  );
};

export default Header;
