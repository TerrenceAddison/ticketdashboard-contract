import { NextComponentType } from "next";

const Footer: NextComponentType = () => {
  return (
    <div className="p-5 border-b2 flex flex-row justify-between items-center">
      <h1 className="py-4 px-4 font-bold">EventDash</h1>
      <h1 className="py-4 px-4 font-bold">
        HackTheMountains X thirdweb X Polygon
      </h1>
    </div>
  );
};

export default Footer;
