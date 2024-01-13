//
//  DrugsListViewModel.swift
//  BNTtest
//
//  Created by Vitaly Anpilov on 13.01.2024.
//

import Foundation

final class DrugsListViewModel {
    // MARK: - Observables
    @Observable
    private (set) var drugs: [Drug] = []
    
    @Observable
    private (set) var isLoading: Bool = false
    
    // MARK: - Properties

    
    // MARK: - Methods
    func viewWillAppear() {
        
    }
    
    private func getCars() {
        
    }
    
}
