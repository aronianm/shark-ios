//
//  ProgramView.swift
//  Shart-IOS
//
//  Created by Michael Aronian Aronian on 9/2/24.
//

import SwiftUI
import FronteggSwift

struct ProgramsView: View {
    @EnvironmentObject var fronteggAuth: FronteggAuth
    @StateObject private var programService: ProgramService
    
    init() {
        _programService = StateObject(wrappedValue: ProgramService(fronteggAuth: FronteggApp.shared.auth))
    }
    @State private var programs: [Program] = []
    @State private var program: Program? = nil
    @State var errorLoadingProgram:Bool = false
    @State var errorLoadingPrograms:Bool = false
    @State var loadingPrograms:Bool = false
    @State var loadingProgram:Bool = false
    
    var body: some View {
        VStack {
            if(loadingPrograms || loadingProgram){
                ProgressView()
            }else{
                if(errorLoadingPrograms){
                    Text("Error fetching programs")
                }
                if(errorLoadingProgram){
                    Text("Error fetching program")
                }
                if(program != nil){
                    if(program != nil){
                        ProgramDetailsView(program: program!)
                    }
                }
                VStack {
                    if programs.isEmpty {
                        Text("No programs available. Find a trainer to get started!")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        List {
                            ForEach(programs, id: \.id) { program in
                                NavigationLink(destination: ProgramDetailsView(program: program)) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(program.name)
                                                .font(.headline)
                                            Text("\(program.workouts.count) workout\(program.workouts.count == 1 ? "" : "s")")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        if !program.started {
                                            Text("Not Started")
                                                .foregroundColor(.red)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 5)
                                                .background(Color.red.opacity(0.1))
                                                .cornerRadius(8)
                                        }
                                    }
                                    .padding()
                                    .background(Color(.systemBackground))
                                    .cornerRadius(10)
                                    .shadow(radius: 3)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal)
                                .padding(.vertical, 4)
                            }
                        }
                        .listStyle(PlainListStyle())
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .refreshable {
                            refreshPrograms()
                        }
                    }
                }.onAppear {
                    programService.fetchPrograms { result in
                        switch result {
                        case .success(let programs):
                            self.programs = programs
                        case .failure(_):
                            self.errorLoadingPrograms = true
                        }
                        self.loadingPrograms = false
                    }
                }
            }
            
        }
    }
    // Add this function outside of the body
    func refreshPrograms() {
        loadingPrograms = true
        errorLoadingPrograms = false
        
        programService.fetchPrograms { result in
            switch result {
            case .success(let fetchedPrograms):
                self.programs = fetchedPrograms
            case .failure(_):
                self.errorLoadingPrograms = true
            }
            self.loadingPrograms = false
        }
    }
}

#Preview {
    ProgramsView()
}
