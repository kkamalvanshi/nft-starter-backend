// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

//importing open zeppelin contracts which implements NFT standards
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "hardhat/console.sol";
import { Base64 } from "contracts/Base64.sol";
//import "contracts/Base64.sol";



//inheriting ERC721URIStorage from import giving access to contract's methods
//ERC 721 is the interface for NFTs
contract MyEpicNFT is ERC721URIStorage {
    //open zeppelin helps keep track of tokenIds
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    //Copied baseSVG from Buildspace
    string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

    string[] firstWords = ["Decisive", "Dry", "Delirious", "Guarded", "Civil", "Blue"];
    string[] secondWords = ["Flying", "Surrounding", "Prompting", "Sitting", "Opting", "Developing"];
    string[] thirdWords = ["Category", "Language", "Distribution", "Theory", "Disk", "Client"];

    event NewEpicNFTMinted(address sender, uint256 tokenId);
    
    //pass name of NFTs and Symbol
    constructor() ERC721 ("RandomWords", "SQUARE") {
        console.log("This is my NFT contract.");
    }

    //Copied random word picker methods from Buildspace (https://gist.github.com/farzaa/b788ba3a8dbaf6f1ef9af57eefa63c27)
    function pickRandomFirstWord(uint256 tokenId) public view returns (string memory) {
        //Seed the random generator
        uint256 rand = random(string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId))));
        //Squash the # between 0 and the length of the array to avoid going out of bounds.
        rand = rand % firstWords.length;
        return firstWords[rand];
    }
    function pickRandomSecondWord(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId))));
        rand = rand % secondWords.length;
        return secondWords[rand];
    }

    function pickRandomThirdWord(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId))));
        rand = rand % thirdWords.length;
        return thirdWords[rand];
    }

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    
    //function user will hit to get their NFT
    function makeAnEpicNFT() public {
        //get tokenID, starting with 0
        //_tokenIds is the unique identifier for each NFT in collection
        //value stored on contract directly
        //each time function is run, newItemId iterates by 1
        uint256 newItemId = _tokenIds.current();

        //Copied code from buildspace (https://gist.github.com/farzaa/b788ba3a8dbaf6f1ef9af57eefa63c27)
        // We go and randomly grab one word from each of the three arrays.
        string memory first = pickRandomFirstWord(newItemId);
        string memory second = pickRandomSecondWord(newItemId);
        string memory third = pickRandomThirdWord(newItemId);
        string memory combinedWord = string(abi.encodePacked(first, second, third));

        //Copied code from buildspace (https://gist.github.com/farzaa/b788ba3a8dbaf6f1ef9af57eefa63c27)
        //Concatenating everything, and then close the <text> and <svg> tags.

        //set NFT's data
        //sets unique identifier along with data associated
        //tokenURI is where NFT Data lives

        //json example:
        //{
        //  "name": "Spongebob Cowboy Pants",
        //  "description": "A silent hero. A watchful protector.",
        //  "image": "https://i.imgur.com/v7U019j.png"
        //} 

        string memory finalSvg = string(abi.encodePacked(baseSvg, combinedWord, "</text></svg>"));

        //declaration taken from: https://gist.github.com/farzaa/5015532446dfdb267711592107a285a9
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        combinedWord,
                        '", "description": "A highly acclaimed collection of squares.", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                   )
                )
            )
        );
        
        //declaration taken from: https://gist.github.com/farzaa/5015532446dfdb267711592107a285a9
        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        //base64 encoding json to 
       
        console.log("\n--------------------");
        console.log(finalSvg);
        console.log("--------------------\n");

        //mint NFT to sender
        //mint NFT with newItemId to user with the address msg.sender
        //msg.sender found by connecting wallet
        _safeMint(msg.sender, newItemId);


        //use jsonkeeper.com to 

        _setTokenURI(newItemId, finalTokenUri);
        //_setTokenURI(newItemId, "data:application/json;base64,ewogICAgIm5hbWUiOiAiRXBpY0xvcmRIYW1idXJnZXIiLAogICAgImRlc2NyaXB0aW9uIjogIkFuIE5GVCBmcm9tIHRoZSBoaWdobHkgYWNjbGFpbWVkIHNxdWFyZSBjb2xsZWN0aW9uIiwKICAgICJpbWFnZSI6ICJkYXRhOmltYWdlL3N2Zyt4bWw7YmFzZTY0LFBITjJaeUI0Yld4dWN6MGlhSFIwY0RvdkwzZDNkeTUzTXk1dmNtY3ZNakF3TUM5emRtY2lJSEJ5WlhObGNuWmxRWE53WldOMFVtRjBhVzg5SW5oTmFXNVpUV2x1SUcxbFpYUWlJSFpwWlhkQ2IzZzlJakFnTUNBek5UQWdNelV3SWo0TkNpQWdJQ0E4YzNSNWJHVStMbUpoYzJVZ2V5Qm1hV3hzT2lCM2FHbDBaVHNnWm05dWRDMW1ZVzFwYkhrNklITmxjbWxtT3lCbWIyNTBMWE5wZW1VNklERTBjSGc3SUgwOEwzTjBlV3hsUGcwS0lDQWdJRHh5WldOMElIZHBaSFJvUFNJeE1EQWxJaUJvWldsbmFIUTlJakV3TUNVaUlHWnBiR3c5SW1Kc1lXTnJJaUF2UGcwS0lDQWdJRHgwWlhoMElIZzlJalV3SlNJZ2VUMGlOVEFsSWlCamJHRnpjejBpWW1GelpTSWdaRzl0YVc1aGJuUXRZbUZ6Wld4cGJtVTlJbTFwWkdSc1pTSWdkR1Y0ZEMxaGJtTm9iM0k5SW0xcFpHUnNaU0krUlhCcFkweHZjbVJJWVcxaWRYSm5aWEk4TDNSbGVIUStEUW84TDNOMlp6ND0iCn0=");
        //https://www.utilities-online.info/base64
        //https://www.svgviewer.dev/
        //https://jsonkeeper.com/
        //tokenURI info example: "data:application/json;base64,ewogICAgIm5hbWUiOiAiRXBpY0xvcmRIYW1idXJnZXIiLAogICAgImRlc2NyaXB0aW9uIjogIkFuIE5GVCBmcm9tIHRoZSBoaWdobHkgYWNjbGFpbWVkIHNxdWFyZSBjb2xsZWN0aW9uIiwKICAgICJpbWFnZSI6ICJkYXRhOmltYWdlL3N2Zyt4bWw7YmFzZTY0LFBITjJaeUI0Yld4dWN6MGlhSFIwY0RvdkwzZDNkeTUzTXk1dmNtY3ZNakF3TUM5emRtY2lJSEJ5WlhObGNuWmxRWE53WldOMFVtRjBhVzg5SW5oTmFXNVpUV2x1SUcxbFpYUWlJSFpwWlhkQ2IzZzlJakFnTUNBek5UQWdNelV3SWo0S0lDQWdJRHh6ZEhsc1pUNHVZbUZ6WlNCN0lHWnBiR3c2SUhkb2FYUmxPeUJtYjI1MExXWmhiV2xzZVRvZ2MyVnlhV1k3SUdadmJuUXRjMmw2WlRvZ01UUndlRHNnZlR3dmMzUjViR1UrQ2lBZ0lDQThjbVZqZENCM2FXUjBhRDBpTVRBd0pTSWdhR1ZwWjJoMFBTSXhNREFsSWlCbWFXeHNQU0ppYkdGamF5SWdMejRLSUNBZ0lEeDBaWGgwSUhnOUlqVXdKU0lnZVQwaU5UQWxJaUJqYkdGemN6MGlZbUZ6WlNJZ1pHOXRhVzVoYm5RdFltRnpaV3hwYm1VOUltMXBaR1JzWlNJZ2RHVjRkQzFoYm1Ob2IzSTlJbTFwWkdSc1pTSStSWEJwWTB4dmNtUklZVzFpZFhKblpYSThMM1JsZUhRK0Nqd3ZjM1puUGc9PSIKfQ=="
        console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);

        //increment counter when next NFT gets minted
        _tokenIds.increment();

        emit NewEpicNFTMinted(msg.sender, newItemId);
    }
}