const express = require('express');
const fs = require('fs');
const path = require('path');

const router = express.Router();

const ledsFilePath = path.join(__dirname, './leds.json');

const getLED = async (req, res, next) => {
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

const getLEDs = async (req, res, next) => {
  try {
    const data = fs.readFileSync(ledsFilePath);
    const leds = JSON.parse(data);
    res.json(leds);
  } catch (e) {
    next(e);
  }
};

const getScene = async (req, res, next) => {
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

const deleteScene = async (req, res, next) => {
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
    const newLEDs = leds.map(led => {
      if (led.id === Number(req.params.ledID)) {
        const newScenes = led.scenes.map(scene => {
		  if (scene.id === Number(req.params.sceneID)) {
			return null;
		  } else {
			return scene;
		  }
		})
		.filter(scene => scene !== null);
		led.scenes = newScenes;
		return led;
      } else {
        return led;
      }
    });
    fs.writeFileSync(ledsFilePath, JSON.stringify(newLEDs));
    res.status(200).end();
  } catch (e) {
    next(e);
  }
};

const createScene = async (req, res, next) => {
  try {
    const data = fs.readFileSync(ledsFilePath);
    const leds = JSON.parse(data);
    const led = leds.find(led => led.id === Number(req.params.ledID));
    if (!led) {
      const err = new Error('LED not found');
      err.status = 404;
      throw err;
    }
    newID = Math.max.apply(Math, led.scenes.map(function(o) { return o.id; })) + 1;
    const newScene = {
      id: newID,
      time: req.body.time,
      color: req.body.color,
      brightness: req.body.brightness,
      mode: req.body.mode,
    };
    led.scenes.push(newScene);
    fs.writeFileSync(ledsFilePath, JSON.stringify(leds));
    res.status(201).json(newScene);
  } catch (e) {
    next(e);
  }
};

const updateScene = async (req, res, next) => {
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
