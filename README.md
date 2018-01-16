# Perfect INI Codable

<p align="center">
    <a href="http://perfect.org/get-involved.html" target="_blank">
        <img src="http://perfect.org/assets/github/perfect_github_2_0_0.jpg" alt="Get Involed with Perfect!" width="854" />
    </a>
</p>

<p align="center">
    <a href="https://github.com/PerfectlySoft/Perfect" target="_blank">
        <img src="http://www.perfect.org/github/Perfect_GH_button_1_Star.jpg" alt="Star Perfect On Github" />
    </a>  
    <a href="http://stackoverflow.com/questions/tagged/perfect" target="_blank">
        <img src="http://www.perfect.org/github/perfect_gh_button_2_SO.jpg" alt="Stack Overflow" />
    </a>  
    <a href="https://twitter.com/perfectlysoft" target="_blank">
        <img src="http://www.perfect.org/github/Perfect_GH_button_3_twit.jpg" alt="Follow Perfect on Twitter" />
    </a>  
    <a href="http://perfect.ly" target="_blank">
        <img src="http://www.perfect.org/github/Perfect_GH_button_4_slack.jpg" alt="Join the Perfect Slack" />
    </a>
</p>

<p align="center">
    <a href="https://developer.apple.com/swift/" target="_blank">
        <img src="https://img.shields.io/badge/Swift-4.0-orange.svg?style=flat" alt="Swift 4.0">
    </a>
    <a href="https://developer.apple.com/swift/" target="_blank">
        <img src="https://img.shields.io/badge/Platforms-OS%20X%20%7C%20Linux%20-lightgray.svg?style=flat" alt="Platforms OS X | Linux">
    </a>
    <a href="http://perfect.org/licensing.html" target="_blank">
        <img src="https://img.shields.io/badge/License-Apache-lightgrey.svg?style=flat" alt="License Apache">
    </a>
    <a href="http://twitter.com/PerfectlySoft" target="_blank">
        <img src="https://img.shields.io/badge/Twitter-@PerfectlySoft-blue.svg?style=flat" alt="PerfectlySoft Twitter">
    </a>
    <a href="http://perfect.ly" target="_blank">
        <img src="http://perfect.ly/badge.svg" alt="Slack Status">
    </a>
</p>

This project provides an encoder / decorder for [INI](https://en.wikipedia.org/wiki/INI_file) files.

This package builds with Swift Package Manager of Swift 4 Tool Chain and is part of the [Perfect](https://github.com/PerfectlySoft/Perfect) project but can be used as an independent module.

## Quick Start

This library provides a pair of `INIEncoder` and `INIDecoder` for INI files.

### Encodable to INI

``` swift
import PerfectINI
struct Person: Codable {
  public var name = ""
  public var age = 0
}

struct Place: Codable {
  public var location = ""
  public var history = 0
}

struct Configuration: Codable {
  public var id = 0
  public var tag = ""
  public var person = Person()
  public var place = Place()
}

let rocky = Person(name: "rocky", age: 21)
let hongkong = Place(location: "china", history: 1000)

let conf = Configuration(id: 101, tag: "my notes", person: rocky, place: hongkong)
let encoder = INIEncoder()
let data = try encoder.encode(conf)
```
The outcome of encoder is a standard Swift `Data` object, and the content should be like this:

``` ini
id = 101
tag = my notes

[person]
name = rocky
age = 21

[place]
history = 1000
location = china
```

### INI to Decodable

Assuming `Configuration` and `data` are ready:

``` swift
let decoder = INIDecoder()
let config = try decoder.decode(Configuration.self, from: data)
// configuration loaded.
```

## Issues

We are transitioning to using JIRA for all bugs and support related issues, therefore the GitHub issues has been disabled.

If you find a mistake, bug, or any other helpful suggestion you'd like to make on the docs please head over to [http://jira.perfect.org:8080/servicedesk/customer/portal/1](http://jira.perfect.org:8080/servicedesk/customer/portal/1) and raise it.

A comprehensive list of open issues can be found at [http://jira.perfect.org:8080/projects/ISS/issues](http://jira.perfect.org:8080/projects/ISS/issues)

## Further Information
For more information on the Perfect project, please visit [perfect.org](http://perfect.org).


## Now WeChat Subscription is Available 🇨🇳
<p align=center><img src="https://raw.githubusercontent.com/PerfectExamples/Perfect-Cloudinary-ImageUploader-Demo/master/qr.png"></p>
