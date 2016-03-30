module CarpiTorque where

type alias Model =
  { power: Float,
    brakePower: Float,
    powerLevel: Float,
    reversedPower: Bool,
    turnDirection: Int
  }

decreasePowerLevel : Model -> Bool -> Model
decreasePowerLevel car brakeApplied =
  let
    currenCarPower =
      if brakeApplied then car.brakePower * car.power else car.power
  in
    (car.powerLevel - currenCarPower) |> normalizedPowerLevel car currenCarPower

increasePowerLevel : Model -> Model
increasePowerLevel car =
  (car.powerLevel + car.power) |> normalizedPowerLevel car car.power

normalizedPowerLevel : Model -> Float -> Float -> Model
normalizedPowerLevel car currenCarPower newPowerLevel =
  let
    powerLevel =
      if abs (car.powerLevel + newPowerLevel) < currenCarPower then 0 else newPowerLevel
  in
    { car | powerLevel = clamp 0 100 powerLevel }

setReverse : Bool -> Model -> Model -> Model
setReverse reversing car updatedCar =
  if reversing then
    if car.powerLevel == 0 then { updatedCar | reversedPower = True } else updatedCar
  else
    if updatedCar.powerLevel == 0 then { updatedCar | reversedPower = False } else updatedCar

applyAccelerate : Model -> Model
applyAccelerate car =
  if car.reversedPower then decreasePowerLevel car True else increasePowerLevel car
    |> setReverse False car

applyReverse : Model -> Model
applyReverse car =
  if car.reversedPower then increasePowerLevel car else decreasePowerLevel car True
    |> setReverse True car

applyEngineDecelerate : Model -> Model
applyEngineDecelerate car =
  if car.powerLevel == 0 then car
  else
    decreasePowerLevel car False |> setReverse False car
