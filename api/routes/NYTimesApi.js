// import {baseUrl} from "./utils";

var express = require("express");
var router = express.Router();
const request = require("request");
const nytimesKey = "newyork times key";
const baseUrl = "http://localhost:8080";

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

function resolveResults(results){
    let articles = [];
    for(let result of results){
        let article = {};
        //resolve first image width >= 2000
        try{
            for(let media of result.multimedia){
                if(media.width >= 2000){
                    article.image = media.url;
                    break;
                }
            }
        }catch (e) {
            console.log("picture not found: " + e);
        }
        if(article.image === undefined || article.image === null){
            article.image = baseUrl + "/images/nytimes.jpg";
        }
        //resolve other property
        try{
            article.title = result.title;
            article.section = result.section;
            article.date = formatDate(result.published_date);
            article.description = result.abstract;
            article.url = result.url;
            article.detailUrl = result.url;
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

function resolveDetailResult(docs){
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
            article.description = result.abstract;
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
            console.log(article);
            articles.push(article);
        }
    }
    return articles;
}

function resolveSearchResults(docs){
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

router.get("/", function(req, res, next) {
    let url = "https://api.nytimes.com/svc/topstories/v2/home.json?api-key=" + nytimesKey;
    request(url, function (err,response,body) {
        if(err || response.statusCode !== 200){
            console.log("request error");
            return res.sendStatus(500);
        }else{
            // console.log(JSON.parse(body));
            let results = JSON.parse(body).results;
            let articles = resolveResults(results);
            res.send(articles);
        }
    })
});

router.get("/:section",function (req,res,next){
    console.log(req.params.section);
    let section = req.params.section === "sport" ? "sports" : req.params.section;
    let url = "https://api.nytimes.com/svc/topstories/v2/" + section + ".json?api-key=" + nytimesKey;
    request(url, function (err,response,body) {
        if(err || response.statusCode !== 200){
            console.log("request error " + response);
            return res.sendStatus(500);
        }else{
            // console.log(JSON.parse(body));
            let results = JSON.parse(body).results;
            let articles = resolveResults(results);
            res.send(articles);
        }
    })
});

router.get("/article/*",function (req,res,next) {
    console.log(req.params[0]);
    let url = "https://api.nytimes.com/svc/search/v2/articlesearch.json?fq=web_url:(\"" + req.params[0] + "\") &api-key=" + nytimesKey;
    request(url,function (err,response,body) {
        if(err || response.statusCode !== 200){
            return res.sendStatus(500);
        }else{
            let detailResult = JSON.parse(body).response.docs;
            let article = resolveDetailResult(detailResult)[0];
            res.send(article);
        }
    })
});

router.get("/search/:query",function (req,res,next) {
    let url = "https://api.nytimes.com/svc/search/v2/articlesearch.json?q=" + req.params.query + "&api-key=" + nytimesKey;
    request(url, function (err,response,body) {
        if(err || response.statusCode !== 200){
            console.log("request error");
            return res.sendStatus(500);
        }else{
            // console.log(JSON.parse(body));
            let results = JSON.parse(body).response.docs;
            let articles = resolveSearchResults(results);
            res.send(articles);
        }
    })
});


module.exports = router;