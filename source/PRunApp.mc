using Toybox.Application;

class PRunApp extends Application.AppBase
{
  function initialize()
  {
    AppBase.initialize();
  }

  
  function onStart(state) 
  {}


  function onStop(state)
  {}
  

  function getInitialView()
  {
    return [ new PRunView() ];
  }
}