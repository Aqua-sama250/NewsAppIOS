var express = require("express");
var router = express.Router();
const request = require("request");
const baseUrl = "http://localhost:8080";

const googleTrends = require('google-trends-api');

router.get("/*", function(req, res, next) {
    googleTrends.interestOverTime({keyword: req.params[0], startTime: new Date('2019-06-01')})
        .then(function(results){

            console.log(typeof (JSON.parse(results)));
            resultList = JSON.parse(results).default.timelineData;
            console.log(resultList);
            // console.log(resultList)
            let valueList = [];
            for(var result of resultList){
                console.log(result);
                if(result.hasData[0]){
                    console.log(result.value[0])
                    valueList.push(result.value[0])
                }
            }
            res.send(valueList)
        })
        .catch(function(err){
            console.error(err);
            return res.sendStatus(500);
        });
});

module.exports = router;