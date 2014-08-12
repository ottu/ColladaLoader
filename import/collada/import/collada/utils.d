module collada.utils;

import std.algorithm;
import std.range;
import std.array;

public import kxml.xml;

XmlNode[] getElements( XmlNode node )
{
    return node.getChildren.filter!"!a.isCData".array;
}

string[] getTexts( XmlNode node )
{
    return node.getChildren.filter!"a.isCData".map!"a.toString".array;
}
