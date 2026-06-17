// Auto-generated. Do not edit!

// (in-package robomaker_simulation_msgs.srv)


"use strict";

const _serializer = _ros_msg_utils.Serialize;
const _arraySerializer = _serializer.Array;
const _deserializer = _ros_msg_utils.Deserialize;
const _arrayDeserializer = _deserializer.Array;
const _finder = _ros_msg_utils.Find;
const _getByteLength = _ros_msg_utils.getByteLength;

//-----------------------------------------------------------


//-----------------------------------------------------------

class RemoveTagsRequest {
  constructor(initObj={}) {
    if (initObj === null) {
      // initObj === null is a special case for deserialization where we don't initialize fields
      this.keys = null;
    }
    else {
      if (initObj.hasOwnProperty('keys')) {
        this.keys = initObj.keys
      }
      else {
        this.keys = [];
      }
    }
  }

  static serialize(obj, buffer, bufferOffset) {
    // Serializes a message object of type RemoveTagsRequest
    // Serialize message field [keys]
    bufferOffset = _arraySerializer.string(obj.keys, buffer, bufferOffset, null);
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type RemoveTagsRequest
    let len;
    let data = new RemoveTagsRequest(null);
    // Deserialize message field [keys]
    data.keys = _arrayDeserializer.string(buffer, bufferOffset, null)
    return data;
  }

  static getMessageSize(object) {
    let length = 0;
    object.keys.forEach((val) => {
      length += 4 + _getByteLength(val);
    });
    return length + 4;
  }

  static datatype() {
    // Returns string type for a service object
    return 'robomaker_simulation_msgs/RemoveTagsRequest';
  }

  static md5sum() {
    //Returns md5sum for a message object
    return '9bf34c7d40859cce227de2428e93c00a';
  }

  static messageDefinition() {
    // Returns full string definition for message
    return `
    # Copyright 2019 Amazon.com, Inc. or its affiliates. All Rights Reserved.
    # SPDX-License-Identifier: Apache-2.0
    #
    # This service is loaded at runtime in AWS RoboMaker simulations.
    #
    # Calling this service will remove tags from the running
    # simulation job.
    #
    # More information about usage can be found here:
    # https://docs.aws.amazon.com/robomaker
    #
    # This uses the UntagResource API:
    # https://docs.aws.amazon.com/robomaker/latest/dg/API_UntagResource.html
    
    # Key values for tags to remove from the simulation job
    string[] keys
    
    `;
  }

  static Resolve(msg) {
    // deep-construct a valid message object instance of whatever was passed in
    if (typeof msg !== 'object' || msg === null) {
      msg = {};
    }
    const resolved = new RemoveTagsRequest(null);
    if (msg.keys !== undefined) {
      resolved.keys = msg.keys;
    }
    else {
      resolved.keys = []
    }

    return resolved;
    }
};

class RemoveTagsResponse {
  constructor(initObj={}) {
    if (initObj === null) {
      // initObj === null is a special case for deserialization where we don't initialize fields
      this.success = null;
      this.message = null;
    }
    else {
      if (initObj.hasOwnProperty('success')) {
        this.success = initObj.success
      }
      else {
        this.success = false;
      }
      if (initObj.hasOwnProperty('message')) {
        this.message = initObj.message
      }
      else {
        this.message = '';
      }
    }
  }

  static serialize(obj, buffer, bufferOffset) {
    // Serializes a message object of type RemoveTagsResponse
    // Serialize message field [success]
    bufferOffset = _serializer.bool(obj.success, buffer, bufferOffset);
    // Serialize message field [message]
    bufferOffset = _serializer.string(obj.message, buffer, bufferOffset);
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type RemoveTagsResponse
    let len;
    let data = new RemoveTagsResponse(null);
    // Deserialize message field [success]
    data.success = _deserializer.bool(buffer, bufferOffset);
    // Deserialize message field [message]
    data.message = _deserializer.string(buffer, bufferOffset);
    return data;
  }

  static getMessageSize(object) {
    let length = 0;
    length += _getByteLength(object.message);
    return length + 5;
  }

  static datatype() {
    // Returns string type for a service object
    return 'robomaker_simulation_msgs/RemoveTagsResponse';
  }

  static md5sum() {
    //Returns md5sum for a message object
    return '937c9679a518e3a18d831e57125ea522';
  }

  static messageDefinition() {
    // Returns full string definition for message
    return `
    # True if tags were successfully removed. False otherwise.
    bool success
    
    # Message containing more information about the error if success
    # is false.
    string message
    
    `;
  }

  static Resolve(msg) {
    // deep-construct a valid message object instance of whatever was passed in
    if (typeof msg !== 'object' || msg === null) {
      msg = {};
    }
    const resolved = new RemoveTagsResponse(null);
    if (msg.success !== undefined) {
      resolved.success = msg.success;
    }
    else {
      resolved.success = false
    }

    if (msg.message !== undefined) {
      resolved.message = msg.message;
    }
    else {
      resolved.message = ''
    }

    return resolved;
    }
};

module.exports = {
  Request: RemoveTagsRequest,
  Response: RemoveTagsResponse,
  md5sum() { return 'cae332c01603844d352ed026669010ee'; },
  datatype() { return 'robomaker_simulation_msgs/RemoveTags'; }
};
