//
//  loyer.swift
//  Jonathan Côté
//

import Foundation


struct Loyer : Identifiable, Codable {
    var id : Int;
    var nom : String;
    var grandeur : Double;
    var longitude: String;
    var lattitude: String;
    var prix: Double;
    var uuid : String;
    var dispo : Bool;
}
