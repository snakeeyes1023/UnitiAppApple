//
//  loyer.swift
//  UnitiApp
//
//  Created by Josee Nolet on 2022-05-04.
//

import Foundation


struct Loyer : Identifiable {
    var id : Int;
    var nom : String;
    var grandeur : Double;
    var prix: Double;
    var uuid : String;
    var dispo : Bool;
}
