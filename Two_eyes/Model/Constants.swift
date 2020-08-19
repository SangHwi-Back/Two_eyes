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
    
    //MARK: - Camera View
    static let filterViewControllerIdentifier = "FilterViewController"
    
    //MARK: - Filter View
    static let filterViewFilters = ["none", "CIColorMonochrome", "CISepiaTone", "CIVignette"
    ]
    static let filterViewAdjustKeys = ["blur", "brightness", "contrast", "opacity"
    ]
    
    //MARK: - Search View
    static let searchCellReuseIdentifier = "albumItems"
    
    //MARK: - Setting View
    static let settings = ["필터 창 설정","카메라 관련 설정","사진검색 관련 설정","정보","일반"]
    static let settingsSegueIdentifier = [
        "필터 창 설정":"filterSettingViewSegue",
        "카메라 관련 설정":"cameraSettingViewSegue",
        "사진검색 관련 설정":"photoLibrarySettingViewSegue",
        "정보":"informationSettingViewSegue",
        "일반":"logoutSegue"]
    static let sections = ["FILTER":1,"CAMERA":1,"PHOTO_LIBRARY":1,"INFORMATION":1,"MAIN":1]
    static let sectionRowCount = [0:1,1:1,2:1,3:1,4:1]
    static let reuseIdentifier = "settingRows"
    
    static let settingsCellTitles =
        ["필터 창 설정":["사진 필터 화면에서 원본 사진 보이기", "미세조정 값 추가 혹은 제거"],
         "카메라 관련 설정":["고해상도 여부","사진촬영 시 플래시 여부"],
         "사진검색 관련 설정":["연도별 사진을 보여줄지 여부","월별 사진을 보여줄지 여부","Two_eyes 에서 촬영한 사진만 보여줄 지 여부","Two_eyes 에서 필터링 한 사진만 보여줄지 여부"],
         "정보":[],
         "로그아웃":[]]
    static let settingsCellReuseIdentifier =
        ["필터 창 설정":"filterSettingReuseIdentifier",
        "카메라 관련 설정":"cameraSettingReuseIdentifier",
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
        "Space_Gray", "Silver" ,"Egg_Tart", "Blue_Jelly", "Milk_Choco"
    ]
    
}
