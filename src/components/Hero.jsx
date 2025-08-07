import React from "react";
import { motion } from "framer-motion";
import { styles } from "../styles";
import { ComputersCanvas } from "./canvas";
import { eyeLogo, meta } from "../assets";

const Hero = () => {
  return (
    <section className="relative w-full h-screen mx-auto">
      <div
        className={`${styles.paddingX} absolute inset-0 top-[120px] max-w-7xl mx-auto flex flex-row items-start gap-5`}
      >
        <div className="flex flex-col justify-center items-center mt-5">
          <div className="w-5 h-5 rounded-full bg-[#915eff]" />
          <div className="w-1 sm:h-80 h-40 violet-gradient" />
        </div>

        <div>
          <h1 className={`${styles.heroHeadText} text-gray-500`}>
            Welcome to <span className="text-[#915eff]">The Eye</span>{" "}
          </h1>
          <p className={`${styles.heroSubText} mt-2 text-white`}>
            {" "}
            A Cybersecurity Society under the CSEA, PSG College of Technology.{" "}
          </p>
          <p className="mt-5 text-gray-400">
            Welcome to The Eye, a Cybersecurity Society! 🔐 <br />
            Are you passionate about the digital realm and the ever-evolving
            world of cybersecurity? <br /><br />
            The Eye is a cybersecurity-focus college society under the Computer Science and Engineering Association
            in PSG College of Technology. We have multiple verticals to help our members learn and practice
            cybersecurity in their every-day life. We organize events in order to increase awareness of Cybersecurity within
            the college, and also perform other activities like research and documentation, secure coding and mock box attacks.
          </p>
          <div className="mt-5 sm:flex flex-cols  lg:flex-row justify-between">
            <img
              src={eyeLogo}
              alt=""
              className="hidden md:mt-24 w-60 h-60 object-contain"
            />

            <div className="flex flex-col">
              <h1 className={`${styles.heroHeadText} mt-10 flex justify-end`}>
                EtherX Event
              </h1>
              <div>
                <p className="mt-10 ml-10 text-gray-400">
                  The Eye, our very own cybersecurity society under CSEA , is hosting an epic 3-day event this September—etherXsummit! 🎉<br/>
                  The theme? Fintech Cybersecurity 💻, and it’s all about diving deep into the crucial role of cybersecurity in the fintech world. 🌐<br/>
                  On Sept 20, 21, 22<br/>
                  What’s in store?<br/><br/>
                  🧠 Workshops<br/>
                  🎓 Guest Speaker Sessions<br/>
                  💼 Case Studies<br/>
                  💻 Speed Run Hackathon<br/>
                  🏆 Prizes and Certificates<br/><br/>
                  Whether you're into fintech, cybersecurity, or just love a good challenge, this is your chance to network, learn, and showcase your skills!<br/>
                  Don't miss out—this could be the event that sparks your next big idea! 🌟
                </p>

                {/*<p className="mt-3 ml-10 text-gray-400">
                  #CyberSecurity #JoinTheEye Join us, and together, let's secure
                  a safer digital future! 🔐🌐💻
                </p>*/}
                <br/><br/>

                <button className="cursor-pointer" onClick={()=>window.open("https://etherx.cseatheeye.com/", "_blank")} style={{textAlign:'right', border:'1px white solid', padding: '5px',float: 'right'}}>
                  Register for the Event
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
};

export default Hero;
