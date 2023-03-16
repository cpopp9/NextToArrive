    //
    //  ContentViewModel_Tests.swift
    //  Next to Arrive_Tests
    //
    //  Created by Cory Popp on 3/13/23.
    //

import XCTest
@testable import Next_to_Arrive

final class ContentViewModel_Tests: XCTestCase {
    
    var viewModel: ContentViewModel?
    
    override func setUpWithError() throws {
            // Put setup code here. This method is called before the invocation of each test method in the class.
        self.viewModel = ContentViewModel()
        
    }
    
    override func tearDownWithError() throws {
            // Put teardown code here. This method is called after the invocation of each test method in the class.
        
        viewModel = nil
    }
    
    func test_ContentViewModel_timeUntilArrival_ShouldBeNilAtInit() {
        
        guard let vm = viewModel else {
            XCTFail()
            return
        }
        
        // Nil at init
        
        XCTAssertNil(vm.timeUntilArrival)
        
        //
        DispatchQueue.main.async {
            vm.busTimes.append(Date())
            vm.calculateTimeUntilNextArrival()
            
            XCTAssertNotNil(vm.timeUntilArrival)
        }
        
    }
    

    
    func test_ContentViewModel_downloadSchedule_ShouldReturnDates() {
        
        let vm = ContentViewModel()
        
        Task {
            let dates = await vm.widgetVM.downloadSchedule(stopID: "3046", route: "2")
            
            XCTAssertGreaterThan(dates.count, 0)
        }
    }
    
    func test_ContentViewModel_snapshotGenerator_ShouldGenerateUIImage() {
        
        guard let vm = viewModel else {
            XCTFail()
            return
        }
        
        // snapshot nil on initialization
        XCTAssertNil(vm.snapshotImage)
        
        // Once snapshot is called, snapshotImage should contain uiImage
        DispatchQueue.main.async {
            vm.snapshotGenerator()
            XCTAssertNotNil(vm.snapshotImage)
        }
        
        DispatchQueue.main.async {
            vm.selectedStop.stop.lat 
        }
    }
    
    
    
    
    
}
