#!/usr/bin/env rdmd

import std.stdio: writeln;
import std.file;
import std.path;
import std.array;
import std.algorithm: joiner;
import std.process;
import std.json;

enum SOURCE_PATH = "./source/";
enum IS_SOURSE = 33188;
enum COMPILER = "dmd";

class Config {
    private {
        string[] _libs;
        string nameApp;
    }
    this(string fileName){
        auto json = parseJSON(readText(fileName));
        foreach(lib ; json["libs"].array) {
            _libs ~= lib.str;
        }
        nameApp = json["nameApp"].str;
    }

    string[] getLibs() {
        return _libs;
    }

    string getNameApp() {
        return nameApp;
    }
}


void main() {
    auto config = new Config("build.json");


    auto command = appender!(string[])();
    command.put(COMPILER);

    foreach (string name; dirEntries(SOURCE_PATH, SpanMode.depth)) {
        if(isDir(name)) {
            continue;
        }
        if (getAttributes(name) != IS_SOURSE) {
            continue;
        }
        if(extension(name) != ".d") {
            continue;
        }
        command.put(name);
    }

    command.put("-of" ~ config.getNameApp());

    foreach(lib ; config.getLibs()) {
        command.put("-L-l" ~ lib);
    }

    command.put("-unittest");
    command.put("-g");
    command.put("-debug");

    writeln(command.data);
    auto pid = spawnProcess(command.data);
    if(wait(pid) != 0) {
        writeln("failed");
    } else {
        writeln("complete");
    }
}
