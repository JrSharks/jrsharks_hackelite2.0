// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
export const firebaseConfig = {
  apiKey: "AIzaSyC3RS_hO3rmdDfW5aZbLmQcn1mvxMtWtgU",
  authDomain: "accessable-f9cf4.firebaseapp.com",
  projectId: "accessable-f9cf4",
  storageBucket: "accessable-f9cf4.firebasestorage.app",
  messagingSenderId: "677379732977",
  appId: "1:677379732977:web:a2f78cdcb062a6c31a0050",
  measurementId: "G-N3LZKT0XK5"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);