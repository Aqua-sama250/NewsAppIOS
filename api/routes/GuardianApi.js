// import {baseUrl} from "./utils";

var express = require("express");
var router = express.Router();
const request = require("request");
const guardianKey = "guardian key";
const baseUrl = "http://localhost:8080";

function formatTimeDiff(date) {
    let d = new Date(date);
    let currDate = new Date();
    let diff = parseInt(currDate - d);
    let diff_hr = parseInt(diff / 1000 / 3600);
    let diff_min = parseInt(diff / 1000 / 60);
    let diff_sec = parseInt(diff / 1000);
    if(diff_hr > 1){
        return diff_hr + "h ago";
    }else if(diff_min > 1){
        return diff_min + "m ago";
    }else{
        return diff_sec + "s ago";
    }
}

function formatTime(date) {

    const months = ["JAN", "FEB", "MAR","APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
    let current_datetime = new Date(date);
    let day = current_datetime.getDate();
    let month = months[current_datetime.getMonth()];
    let year = current_datetime.getFullYear();
    if (day < 10)
        day = '0' + day;
    return day + " " + month + " " + year;
}

function resolveResults(results){
    let articles = [];
    for (let result of results){
        let article = {};
        if(result.fields === null || result.fields.thumbnail == null){
            article.image = baseUrl + "/images/guardian.png";
        }else{
            article.image = result.fields.thumbnail;
        }
        if(result.webTitle !== null && result.webPublicationDate !== null
            && result.sectionName !== null && result.id !== null){
            article.title = result.webTitle;
            article.timediff = formatTimeDiff(result.webPublicationDate);
            article.time = formatTime(result.webPublicationDate);
            article.section = result.sectionName;
            article.id = result.id;
            articles.push(article);
        }
        if(articles.length >= 10){
            break;
        }
    }
    return articles;
}

function resolveDetailResult(content){
    let article = {};
    try{
        let assets = content.blocks.main.elements[0].assets;
        article.image = assets[assets.length - 1].file;
    }catch (e) {
        console.log(e);
        article.image = baseUrl + "/images/guardian.png";
    }
    if(article.image === null){
        article.image = baseUrl + "/images/guardian.png";
    }
    try{
        article.title = content.webTitle;
        article.time = formatTime(content.webPublicationDate);
        article.timediff = formatTimeDiff(content.webPublicationDate);
        article.section = content.sectionName;
        article.articleUrl = content.webUrl;
        article.description = "";
        for(let part of content.blocks.body){
            article.description += part.bodyHtml;
        }
        // article.description = content.blocks.body[0].bodyTextSummary;
    }catch (e) {
        console.log("Missing data in detail article" + e);
    }
    // console.log(article);
    return article;
}

function resolveSectionandSearchResult(results){
    let articles = [];
    for (let result of results){
        let article = {};
        try{
            let assets = result.blocks.main.elements[0].assets;
            article.image = assets[assets.length - 1].file;
        }catch (e) {
            console.log(e);
            article.image = baseUrl + "/images/guardian.png";
        }
        if(article.image === null){
            article.image = baseUrl + "/images/guardian.png";
        }
        if(result.webTitle !== null && result.webPublicationDate !== null
            && result.sectionName !== null && result.id !== null){
            article.title = result.webTitle;
            article.timediff = formatTimeDiff(result.webPublicationDate);
            article.time = formatTime(result.webPublicationDate)
            article.section = result.sectionName;
            article.id = result.id;
            articles.push(article);
        }
        if(articles.length >= 10){
            break;
        }
    }
    return articles;
}

router.get("/", function(req, res, next) {
    let url = "https://content.guardianapis.com/search?orderby=newest&show-fields=starRating,headline,thumbnail,short-url&api-key=" + guardianKey;
    request(url, function (err,response,body) {
        if(err || response.statusCode !== 200){
            return res.sendStatus(500);
        }else{
            let results = JSON.parse(body).response.results;
            let articles = resolveResults(results);
            // console.log(articles);
            res.send(articles);
        }
    })
});

router.get("/section/:section",function (req,res,next) {
    let sectionName = req.params.section === "sports"? "sport" : req.params.section;
    let url = "https://content.guardianapis.com/" + sectionName + "?api-key=" + guardianKey + "&show-blocks=all&page-size=30";
    request(url,function (err,response,body) {
        if(err || response.statusCode !== 200){
            return res.sendStatus(500);
        }else{
            console.log("section")
            let results = JSON.parse(body).response.results;
            let articles = resolveSectionandSearchResult(results);
            res.send(articles);
        }
    })
});

router.get("/article/*",function (req,res,next) {
    console.log(req.params[0]);
    let url = "https://content.guardianapis.com/" + req.params[0] + "?api-key=" + guardianKey + "&show-blocks=all";
    request(url,function (err,response,body) {
        if(err || response.statusCode !== 200){
            return res.sendStatus(500);
        }else{
            let detailResult = JSON.parse(body).response.content;
            let article = resolveDetailResult(detailResult);
            res.send(article);
        }
    })
});

router.get("/search",function (req,res,next) {
    console.log(req.query)
    let url = "https://content.guardianapis.com/search?q=" + req.query.keyword + "&api-key=" + guardianKey + "&show-blocks=all&page-size=30";
    request(url,function (err,response,body) {
        if(err || response.statusCode !== 200){
            return res.sendStatus(500);
        }else{
            let results = JSON.parse(body).response.results;
            let articles = resolveSectionandSearchResult(results);
            res.send(articles);
        }
    })
});

module.exports = router;