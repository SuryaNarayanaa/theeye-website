import { SectionWrapper } from "../HOC";
import { logo } from "../assets";
import { Link } from "react-router-dom";
import {
  AiOutlineInstagram,
  AiOutlineLinkedin,
  AiOutlineMediumWorkmark,
} from "react-icons/ai";

const footer = () => {
  return (
    <footer className="min-w-max h-max mx-auto flex flex-col justify-center">
      <div className="flex text-red-400 justify-center">
        <Link
          to="/"
          className="flex items-center gap-2"
          onClick={() => {
            window.scrollTo(0, 0);
          }}
        >
          <img src={logo} alt="logo" className="w-96 h-96 object-contain" />
        </Link>
      </div>
       <p className="mx-auto mb-5">Important Links to Visit </p> 
      <div className="flex flex-col md:flex-row justify-center opacity-70 mb-20">
        <ul className="flex flex-col md:flex-row mx-auto gap-5 hover:divide-sky-900">
          <a href="http://f2e7dezm47yrddezmlvzrogkon2ljb4kewn5xyik2ozfrvdkufn7gfad.onion/">
            Visit in TOR
          </a>
          <a href="https://cybercrime.gov.in/">
            Report Cybercrimes to the Government of India
          </a>
          <a href="https://www.ceir.gov.in/Request/CeirUserBlockRequestDirect.jsp">
            Request blocking lost/stolen mobile
          </a>
          <a href="https://nciipc.gov.in/index.html">
            National Critical Information Infrastructure
          </a>
          <a href="https://nciipc.gov.in/index.html">Protection Center</a>
          <a href="https://cert-in.org.in/">CERT-IN</a>
        </ul>
      </div>
      <ul className="flex flex-col justify-center items-center md:flex-row gap-10 pb-5">
        <a href="https://www.instagram.com/theeye.network/">
          <AiOutlineInstagram size={30} md:size={50} />
        </a>

        <a href="https://www.linkedin.com/company/visio-protectoris">
          <AiOutlineLinkedin size={30} md:size={50} />
        </a>
        <a href="https://medium.com/@welcometotheeye">
          <AiOutlineMediumWorkmark size={30} md:size={50} />
        </a>
      </ul>
      {/*<div className="flex flex-col justify-center items-center md:flex-row  opacity-50 mb-20 mt-10 ml-7">
        <div>Website Developed by Team Oculus UI</div>
        
        <div className="ml-2">
        <a href="https://join.cseatheeye.com/auth"> | JOIN THE EYE</a>
           </div>
      </div>*/}
      
      {/* New Section for Team Members */}
      <div className="flex flex-col justify-center items-center md:flex-row gap-5 mb-10">
        <span>Main Contributor:</span>
        <a href="https://www.linkedin.com/in/navaneetha-krishnan-k-s-5b7994224/" target="_blank" className="text-blue-600 hover:underline">
          Navaneetha Krishnan K S
        </a>
        <span>Other Contributors:</span>
        <a href="https://www.linkedin.com/in/keerti-dhanyaa-r-412496275" target="_blank" className="text-blue-600 hover:underline">
          Keerti Dhanyaa R
        </a>
        <a href="https://www.linkedin.com/in/aadityarengarajan" target="_blank" className="text-blue-600 hover:underline">
          Aaditya Rengarajan
        </a>
      </div>

    </footer>
  );
};
export default footer;
// export default SectionWrapper( footer ,  "footer" )
