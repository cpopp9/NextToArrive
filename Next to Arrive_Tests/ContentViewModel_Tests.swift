    //
    //  ContentViewModel_Tests.swift
    //  Next to Arrive_Tests
    //
    //  Created by Cory Popp on 3/13/23.
    //

import XCTest
@testable import Next_to_Arrive

final class ContentViewModel_Tests: XCTestCase {
    
    override func setUpWithError() throws {
            // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
            // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
//    func test_ContentViewModel_SnapshotGenerator_ShouldCreateImage() {
//            // Given
//        
//        let vm = ContentViewModel()
//        
//            // When
//        vm.snapshotGenerator()
//        
//            // Then
//            //        XCTAssertNotNil(vm.snapshotImage)
//    }
    
    func test_ContentViewModel_downloadSchedule_ShouldReturnDates() {
            // Given
        
        let vm = ContentViewModel()
        
            // When
        
        Task {
            var dates = await vm.widgetVM.downloadSchedule(stopID: "3046", route: "2")
            
                // Then
            XCTAssertGreaterThan(dates.count, 0)
        }
        
        
    }
    
}
