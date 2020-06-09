// import {baseUrl} from "./utils";

var express = require("express");
var router = express.Router();
const request = require("request");
const guardianKey = "guardian key";
const nytimesKey = "newyork times key";
const baseUrl = "http://localhost:8080";
const axios = require('axios');
const rp = require('request-promise');

function formatDate(date) {
    let d = new Date(date),
        month = '' + (d.getMonth() + 1),
        day = '' + d.getDate(),
        year = d.getFullYear();

    if (month.length < 2)
        month = '0' + month;
    if (day.length < 2)
        day = '0' + day;

    return [year, month, day].join('-');
}

function resolveGuardian(results){
    let articles = [];
    for (let result of results){
        let article = {};
        try{
            let assets = result.blocks.main.elements[0].assets;
            article.image = assets[assets.length - 1].file;
        }catch (e) {
            console.log("picture not found: " + e);
            article.image = baseUrl + "/images/guardian.png";
        }
        try{
            article.title = result.webTitle;
            article.section = result.sectionId;
            article.date = formatDate(result.webPublicationDate);
            // article.description = result.blocks.body[0].bodyTextSummary;
            article.url = result.webUrl;
            article.detailUrl = result.id;
            article.src = "GuardianAPI";
            articles.push(article);
        }catch (e) {
            console.log(e)
        }
    }
    return articles;
}

function resolveNYTimes(docs){
    let articles = [];
    for(let result of docs){
        let article = {};
        //resolve first image width >= 2000
        try{
            for(let media of result.multimedia){
                if(media.width >= 2000){
                    article.image = "https://www.nytimes.com/" + media.url;
                    break;
                }
            }
        }catch (e) {
            console.log("picture not found: " + e);
        }
        if(article.image === undefined){
            article.image = baseUrl + "/images/nytimes.jpg";
        }
        //resolve other property
        try{
            article.title = result.headline.main;
            article.section = result.news_desk;
            article.date = formatDate(result.pub_date);
            article.url = result.web_url;
            article.detailUrl = result.web_url;
            article.src = "NYTimesAPI";
            articles.push(article);
        }catch (e) {
            console.log(e)
        }
        let isMissingValue = false;
        for(let key in article){
            if(article[key] === null || article[key] === undefined){
                isMissingValue = true;
                break;
            }
        }
        if(!isMissingValue){
            articles.push(article);
        }
    }
    return articles;
}

function merge10(a1,a2) {
    //put a2 to a1 till a1.length == 10
    //a2 > a1
    for(let i = 0; i < a2.length; i++){
        a1.push(a2[i]);
        if(a1.length >= 10){
            break;
        }
    }
    return a1;
}

function resolveSearchNum(a1, a2){
    let results = [];
    if(a1.length >= 5 && a2.length >= 5){
        for(let i = 0; i < 5; i++){
            results.push(a1[i]);
            results.push(a2[i]);
        }
    }else if(a1.length >= 5 && a2.length < 5){
        results = merge10(a2,a1);
    }else if(a1.length < 5 && a2.length >= 5){
        results = merge10(a1,a2);
    }else{
        for(let i = 0; i < a1.length; i++){
            results.push(a1[i]);
        }
        for(let i = 0; i < a2.length; i++){
            results.push(a2[i]);
        }
    }
    return results;
}

router.get("/:query",function (req,res,next) {
    let urlGuardian = "https://content.guardianapis.com/search?q=" + req.params.query + "&api-key=" + guardianKey + "&show-blocks=all";
    let urlNYTimes = "https://api.nytimes.com/svc/search/v2/articlesearch.json?q=" + req.params.query + "&api-key=" + nytimesKey;
    const requestGuardian = axios.get(urlGuardian);
    const requestNYTimes = axios.get(urlNYTimes);
    axios.all([requestGuardian,requestNYTimes]).then(axios.spread((...responses) => {
        const responseGuardian = responses[0];
        const responseNYTimes = responses[1];
        let resultsGuardian = responseGuardian.data.response.results;
        let articlesGuardian = resolveGuardian(resultsGuardian);
        let resultsNYTimes = responseNYTimes.data.response.docs;
        let articlesNYTimes = resolveNYTimes(resultsNYTimes);
        let results = resolveSearchNum(articlesGuardian, articlesNYTimes);
        // for(let article of articlesNYTimes){
        //     articlesGuardian.push(article);
        // }
        res.send(results);
    })).catch(errors => {
        // react on errors.
        console.log(errors)
    })
});

module.exports = router;