const express = require('express');
const fs = require('fs');
const path = require('path');

const router = express.Router();

const ledsFilePath = path.join(__dirname, './leds.json');

const getLED = (req, res, next) => {
  try {
    const data = fs.readFileSync(ledsFilePath);
    const leds = JSON.parse(data);
    const led = leds.find(led => led.id === Number(req.params.ledID));
    if (!led) {
      const err = new Error('LED not found');
      err.status = 404;
      throw err;
    }
    res.json(led);
  } catch (e) {
    next(e);
  }
};

const getLEDs = (req, res, next) => {
  try {
    const data = fs.readFileSync(ledsFilePath);
    const leds = JSON.parse(data);
    res.json(leds);
  } catch (e) {
    next(e);
  }
};

const getScene = (req, res, next) => {
  try {
    const data = fs.readFileSync(ledsFilePath);
    const leds = JSON.parse(data);
    const led = leds.find(led => led.id === Number(req.params.ledID));
    if (!led) {
      const err = new Error('LED not found');
      err.status = 404;
      throw err;
    }
    const scene = led.scenes.find(scene => scene.id === Number(req.params.sceneID));
    if (!scene) {
      const err = new Error('scene not found');
      err.status = 404;
      throw err;
    }
    res.json(scene);
  } catch (e) {
    next(e);
  }
};

const deleteScene = (req, res, next) => {
  try {
    const data = fs.readFileSync(ledsFilePath);
    const leds = JSON.parse(data);
    const led = leds.find(led => led.id === Number(req.params.ledID));
    if (!led) {
      const err = new Error('LED not found');
      err.status = 404;
      throw err;
    }
    const scene = led.scenes.find(scene => scene.id === Number(req.params.sceneID));
    if (!scene) {
      const err = new Error('scene not found');
      err.status = 404;
      throw err;
    }
    led.scenes = led.scenes.filter(scene => scene.id !== Number(req.params.sceneID));
    console.log(led);
    fs.writeFileSync(ledsFilePath, JSON.stringify(leds));
    res.status(200).end();
  } catch (e) {
    next(e);
  }
};

const createScene = (req, res, next) => {
  try {
    const data = fs.readFileSync(ledsFilePath);
    const leds = JSON.parse(data);
    const led = leds.find(led => led.id === Number(req.params.ledID));
    if (!led) {
      const err = new Error('LED not found');
      err.status = 404;
      throw err;
    }
    newID = Math.max.apply(Math, led.scenes.map(o => { return o.id; })) + 1;
    const newScene = {}; //I believe this is where the error occurs.
    //if I don't initialize the const and just do const newScene; then when I run "node app.js"
    //there is a missing initializer in const error. That's why I made it empty {}.
    //But now there is a TypeError when trying to assign to a constant variable.
    if(req.body.hasOwnProperty("day_of_week"))
      {
        newScene = {
          id: newID,
          color: req.body.color,
          brightness: req.body.brightness,
          mode: req.body.mode,
          day_of_week: req.body.day_of_week,
          start_time: req.body.start_time
        };
      }
    else if(req.body.hasOwnProperty("date"))
      {
        newScene = {
          id: newID,
          color: req.body.color,
          brightness: req.body.brightness,
          mode: req.body.mode,
          date: req.body.date,
          start_time: req.body.start_time
        };
      }
    else if(req.body.hasOwnProperty("override_duration"))
      {
        newScene = {
          id: newID,
          color: req.body.color,
          brightness: req.body.brightness,
          mode: req.body.mode,
          override_duration: req.body.override_duration,
          start_time: req.body.start_time
        };
      }
    else
    {
      const err = new Error('Invalid scene specification');
      err.status = 404;
      throw err;
    }

    led.scenes.push(newScene);
    fs.writeFileSync(ledsFilePath, JSON.stringify(leds));
    res.status(201).json(newScene);
  } catch (e) {
    next(e);
  }
};

const updateScene = (req, res, next) => {
  try {
    const data = fs.readFileSync(ledsFilePath);
    const leds = JSON.parse(data);
    const led = leds.find(led => led.id === Number(req.params.ledID));
    if (!led) {
      const err = new Error('LED not found');
      err.status = 404;
      throw err;
    }
    const scene = led.scenes.find(scene => scene.id === Number(req.params.sceneID));
    if (!scene) {
      const err = new Error('scene not found');
      err.status = 404;
      throw err;
    }
    scene.time = req.body.time;
    scene.color = req.body.color;
    scene.brightness = req.body.brightness;
    scene.mode = req.body.mode;
    fs.writeFileSync(ledsFilePath, JSON.stringify(leds));
    res.status(200).json(scene);
  } catch (e) {
    next(e);
  }
};


router
  .route('/leds')
  .get(getLEDs);

router
  .route('/leds/:ledID')
  .get(getLED)

router
  .route('/leds/:ledID/scenes')
  .get(getLED)
  .post(createScene);
  
router
  .route('/leds/:ledID/scenes/:sceneID')
  .get(getScene)
  .put(updateScene)
  .delete(deleteScene);
  
module.exports = router;
