# -*- encoding : utf-8 -*-

Object.include CoreExtensions::Object
Module.include CoreExtensions::Module
Hash.extend CoreExtensions::Hash::ClassMethods
Hash.include CoreExtensions::Hash::Merging
Array.include CoreExtensions::Array
