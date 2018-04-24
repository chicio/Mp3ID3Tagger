# Mp3ID3Tagger

[![Build Status](https://travis-ci.org/chicio/Mp3ID3Tagger.svg?branch=master)](https://travis-ci.org/chicio/Mp3ID3Tagger?branch=master)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/chicio/Mp3ID3Tagger/master/LICENSE.md)
[![Supported platform](https://img.shields.io/badge/platforms-macOS-orange.svg)](https://img.shields.io/badge/platforms-macOS-orange.svg)

![Mp3ID3Tagger: A macOS application to edit the ID3 tag of your mp3 files](https://raw.githubusercontent.com/chicio/Mp3ID3Tagger/master/Assets/Icon-logo-background.png?cc 
"A macOS application to edit the ID3 tag of your mp3 files")

A macOS application to edit the ID3 tag of your mp3 files. You can download the application from [this link]().

## Description

Mp3ID3Tagger support the following ID3 tag versions: 2.2. and 2.3.
It will let you modify the following information inside the ID3 tag of you mp3 file:

* version of the tag
* title
* artist
* album
* year 
* track position
* genre
* attached picture set as Front cover

## Technical details

The application is entirely written in swift. It relays on a swift library I developed to edit ID3 tags of mp3 files: [ID3TagEditor](https://github.com/chicio/ID3TagEditor "ID3 tag editor").
The application has been built using RxSwift and RxCocoa as an experiment to apply the reactive programming paradigm in a real project.
The architectural pattern used to build the application is the Model-View-ViewModel. 
 