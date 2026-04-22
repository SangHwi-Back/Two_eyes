//
//  CGSize+Operator.swift
//  iosApp
//
//  Created by SangHwiBack on 4/22/26.
//

import UIKit

// 0. 연산자 우선순위 그룹 정의
precedencegroup SizePrecedence {
    higherThan: AdditionPrecedence // 우선순위 수준 설정
    lowerThan: MultiplicationPrecedence
    associativity: left // 결합 방향: left, right, none
    assignment: false // 할당 연산자 여부
}
// 1. 연산자 선언
infix operator * : SizePrecedence
infix operator + : SizePrecedence
// 2. 연산자 정의
func * (left: CGSize, right: CGFloat) -> CGSize {
    return CGSize(width: left.width * right, height: left.height * right)
}
func + (left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width * right.width, height: left.height * right.height)
}
