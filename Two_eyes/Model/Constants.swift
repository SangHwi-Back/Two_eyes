//
//  Constants.swift
//  Two_eyes
//
//  Created by 백상휘 on 2020/07/26.
//  Copyright © 2020 Sanghwi Back. All rights reserved.
//

import Foundation

class Constants {
    //MARK: - Common Things
    static let loginAlertMessage = "로그인 에러"
    static let emailFieldNilMessage = "아이디(이메일)을 입력해주시기 바랍니다."
    static let passwordFieldNilMessage = "비밀번호를 입력해주시기 바랍니다."
    static let signInFailedMessage = "로그인에 실패하였습니다."
    static let loginInformationIncorrectMessage = "아이디와 비밀번호가 맞지 않습니다."
    static let normalErrorMessage = "에러가 발생하였습니다."
    static let themeEntityName = "ApplicationTheme"
    
    //MARK: - SingIn View
    static let signUpSegueIdentifier = "signUpSegue"
    
    //MARK: - SignUp View
    static let duplicateUserDetectedMessage = "중복된 사용자가 존재합니다."
    static let lastNameFieldNilMessage = "'이름'을 입력하지 않으셨습니다."
    static let firstNameFieldNilMessage = "'성'을 입력하지 않으셨습니다."
    static let addressFieldNilMessage = "'주소'를 입력하지 않으셨습니다."
    
    //MARK: - Confirm View
    static let confirmSignUpSegueIdentifier = "getConfirmCodeSegue"
    static let signUpSuccessMessage = "사용자 생성을 완료하였습니다. 재로그인해주시기 바랍니다."
    static let signUpFailedMessage = "사용자 생성 에러"
    static let signUpFailedMessageDescription = "사용자 생성 에러\n사용자 생성 도중 에러가 발생하였습니다.\n관리자에게 문의 바랍니다."
    static let signInCompleteSegueIdentifier = "signInComplete"
    
    //MARK: - Camera View
    static let filterViewControllerIdentifier = "FilterViewController"
    
    //MARK: - Filter View
    static let filterViewFilters = ["none", "CIColorMonochrome", "CISepiaTone", "CIVignette", "CIPhotoEffectTonal"
    ]
    static let filterViewAdjustKeys = ["blur", "brightness", "contrast", "opacity"
    ]
    
    //MARK: - Search View
    static let searchCellReuseIdentifier = "albumItems"
    
    //MARK: - Setting View
    static let settings = ["필터 창 설정","사진검색 관련 설정","정보","일반"]
    static let settingsSegueIdentifier = [
        "필터 창 설정":"filterSettingViewSegue",
        "사진검색 관련 설정":"photoLibrarySettingViewSegue",
        "정보":"informationSettingViewSegue",
        "일반":"logoutSegue"]
    static let sections = ["FILTER":1,"PHOTO_LIBRARY":1,"INFORMATION":1,"MAIN":1]
    static let sectionRowCount = [0:1,1:1,2:1,3:1,4:1]
    static let reuseIdentifier = "settingRows"
    
    static let settingsCellTitles =
        ["필터 창 설정":["사진 필터 화면에서 원본 사진 보이기", "미세조정 값 추가 혹은 제거"],
         "사진검색 관련 설정":["연도별 사진을 보여줄지 여부","월별 사진을 보여줄지 여부","Two_eyes 에서 촬영한 사진만 보여줄 지 여부","Two_eyes 에서 필터링 한 사진만 보여줄지 여부"],
         "정보":[],
         "로그아웃":[]]
    static let settingsCellReuseIdentifier =
        ["필터 창 설정":"filterSettingReuseIdentifier",
        "사진검색 관련 설정":"photoLibrarySettingReuseIdnetifier",
        "정보":"",
        "로그아웃":""]
    
    
    //MARK: - FilterSetting View
    
    
    //MARK: - CameraSetting View
    static let cameraSettingTypes = [
        "Sony","PanaSonic","Fuji","EOS"
    ]
    
    //MARK: - MainSetting View
    static let applicationThemeNames = [
        "Default", "Space_Gray", "Silver" ,"Egg_Tart", "Blue_Jelly", "Milk_Choco"
    ]
    static let applicationDefaultThemes = [
        "Default":["id":"Default","nav_tabBar_Color":"","button_Color":"","buttonText_Color":"","bodyText_Color":"","backGround_Color":""],
        "Space_Gray":["id":"Space_Gray","nav_tabBar_Color":"44.44.46","button_Color":"72.72.74","buttonText_Color":"255.255.255","bodyText_Color":"255.255.255","backGround_Color":"142.142.147"],
        "Silver":["id":"Silver","nav_tabBar_Color":"199.199.204","button_Color":"142.142.147","buttonText_Color":"255.255.255","bodyText_Color":"255.255.255","backGround_Color":"229.229.234"],
        "Egg_Tart":["id":"Egg_Tart","nav_tabBar_Color":"157.11.11","button_Color":"218.45.45","buttonText_Color":"255.255.255","bodyText_Color":"255.255.255","backGround_Color":"246.218.99"],
        "Blue_Jelly":["id":"Blue_Jelly","nav_tabBar_Color":"94.233.255","button_Color":"62.100.255","buttonText_Color":"255.255.255","bodyText_Color":"255.255.255","backGround_Color":"236.252.255"],
        "Milk_Choco":["id":"Milk_Choco","nav_tabBar_Color":"145.91.74","button_Color":"92.77.77","buttonText_Color":"255.255.255","bodyText_Color":"255.255.255","backGround_Color":"242.241.231"],
        "RX-78":["id":"RX-78","nav_tabBar_Color":"255.0.0","button_Color":"0.0.255","buttonText_Color":"255.255.255","bodyText_Color":"255.0.255","backGround_Color":"255.255.255"]
    ]
    static let themeKeys = [
        "nav_tabBar_Color","backGround_Color","button_Color","buttonText_Color","bodyText_Color"
    ]
    static let applicationDefaultThemesHEX = [
        ThemeInfo(
            rootBackgroundViewColor: "#8e8e93",
            navigationBackgroundColor: "#2c2c2e",
            buttonBackgroundColor: "",
            buttonTintColor: "#ffffff",
            buttonTextColor: "#ffffff",
            labelTintColor: "#ffffff",
            textFieldTintColor: "#ffffff",
            bodyTextColor: "#ffffff",
            collectionViewBackgroundColor: "#ffffff",
            searchBarBackgroundColor: "4f4f4f",
            contents: "스페이스 그레이 느낌의 테마",
            themeName: "Space_Gray"),
        ThemeInfo(
            rootBackgroundViewColor: "#ffffff",
            navigationBackgroundColor: "#c7c7cc",
            buttonBackgroundColor: "",
            buttonTintColor: "#3d3d3d",
            buttonTextColor: "#000000",
            labelTintColor: "#3d3d3d",
            textFieldTintColor: "#3d3d3d",
            bodyTextColor: "#000000",
            collectionViewBackgroundColor: "#ffffff",
            searchBarBackgroundColor: "3d3d3d",
            contents: "은색 느낌의 테마",
            themeName: "Silver"),
        ThemeInfo(
            rootBackgroundViewColor: "#f6da63",
            navigationBackgroundColor: "#e34d02",
            buttonBackgroundColor: "#e34d02",
            buttonTintColor: "#ffffff",
            buttonTextColor: "#000000",
            labelTintColor: "#ffffff",
            textFieldTintColor: "#ffffff",
            bodyTextColor: "#000000",
            collectionViewBackgroundColor: "#f69463",
            searchBarBackgroundColor: "ffffff",
            contents: "에그타르트 느낌의 테마",
            themeName: "EggTart"),
        ThemeInfo(
            rootBackgroundViewColor: "#9ce8ff",
            navigationBackgroundColor: "#c4e5ff",
            buttonBackgroundColor: "#c4e5ff",
            buttonTintColor: "#0091ff",
            buttonTextColor: "#ffffff",
            labelTintColor: "#0091ff",
            textFieldTintColor: "#0091ff",
            bodyTextColor: "#ffffff",
            collectionViewBackgroundColor: "#4fd6ff",
            searchBarBackgroundColor: "#0091ff",
            contents: "바다 속 느낌의 테마",
            themeName: "BlueJelly"),
        ThemeInfo(
            rootBackgroundViewColor: "#e0593a",
            navigationBackgroundColor: "#5c4d4d",
            buttonBackgroundColor: "#5c4d4d",
            buttonTintColor: "#a33434",
            buttonTextColor: "#ffffff",
            labelTintColor: "#a33434",
            textFieldTintColor: "#a33434",
            bodyTextColor: "#ffffff",
            collectionViewBackgroundColor: "#ffffff",
            searchBarBackgroundColor: "a33434",
            contents: "초콜릿 느낌의 테마",
            themeName: "MilkChoco"),
    ]
    
}
