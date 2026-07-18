//: [Previous](@previous)
import UIKit
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
//: # 의존성 설정(순서설정)하는 방법
//: ### 오퍼레이션간의 순서를 정하고, 순서대로 실행하기 위한 방법

//: 이미지 다운로드하는 첫번째 (비동기)오퍼레이션 정의
// (1) 이미지 다운로드하는 비동기 오퍼레이션
class ImageLoadOperation: AsyncOperation {
    var inputName: String?
    var outputImage: UIImage?
    
    override func main() {
        // 이 메서드는 잠깐 sleep했다가 이미지를 반환하는 시뮬레이팅 메서드임.
        simulateAsyncNetworkLoadImage(named: self.inputName) {
            [unowned self] (image) in
            self.outputImage = image
            self.state = .finished
        }
    }
}

//: 2-1 데이터전달을 위한 프로토콜 정의 및 채택
// 🔸🔸🔸 1) 데이터를 넘겨주기위한 프로토콜 정의하기
protocol FilterDataProvider {
    var image: UIImage? { get }
}

// 프로토콜 채택하기
extension ImageLoadOperation: FilterDataProvider {
    var image: UIImage? { return outputImage }
}


//: 이미지변형하는 두번째 오퍼레이션 정의
//=========================================================
// (원래형태의) 이미지 변형하는 오퍼레이션 (비교해 보기 위한)
class TiltShiftOperation1: Operation {
    var inputImage: UIImage?
    var outputImage: UIImage?
    
    override func main() {
        guard let inputImage = inputImage else { return }
        outputImage = tiltShift(image: inputImage)
    }
}
// =======================================================

//: 2-2 데이터 뽑아서 사용하기 위한 함수 내용을 main()에 정의
// (2) 이미지 변형하는 오퍼레이션 (동기 함수)
class TiltShiftOperation: Operation {
    var inputImage: UIImage?
    var outputImage: UIImage?
    
    override func main() {
        // 🔸🔸🔸 2) 프로토콜 채택한 앞의 오퍼레이션에서, 인풋값을 얻어내기
        if inputImage == .none,    // 인풋이미지가 없으면,
            let dependencyImageProvider = dependencies
                .filter({ $0 is FilterDataProvider})
                .first as? FilterDataProvider {   // (의존하고 있는) 오퍼레이션의 배열에서 오퍼레이션 꺼내기
                inputImage = dependencyImageProvider.image
        }
        
        // 실제 작업
        outputImage = tiltShift(image: inputImage)
    }
}


//: 오퍼레이션 생성
let imageLoad = ImageLoadOperation()
let filter = TiltShiftOperation()

imageLoad.inputName = "train_day.jpg"


//: 1.의존성 설정
// 🔸🔸🔸 의존성 설정 "filter오퍼레이션"이 "imageLoad오퍼레이션"에 의존한다.
filter.addDependency(imageLoad)


//: 두개의 오퍼레이션을 오퍼레이션큐에 넣어서 진행 확인
let queue = OperationQueue()

// 큐에 오퍼레이션 넣기 (동기적으로 기다리게 해서 확인해보기)
//timeCheck {
queue.addOperations([imageLoad, filter], waitUntilFinished: true)
//}


imageLoad.outputImage
filter.outputImage



sleep(3)
PlaygroundPage.current.finishExecution()







/*
* Copyright (c) 2016 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

//: [Next](@next)
