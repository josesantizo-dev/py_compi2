import React from 'react';
import './App.css';
import Main from "./components/main";
import { BrowserRouter as Router, Route } from "react-router-dom";


function App() {
  return (
    <div>
      <Router basename="/py_compi2">
        <Route path="/" exact component={Main} />
      </Router>
    </div>
  );
}

export default App;
